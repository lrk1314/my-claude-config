#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 读取配置文件
let config = {};
const configPath = join(__dirname, 'config.json');
if (fs.existsSync(configPath)) {
  config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
}

const server = new Server(
  {
    name: "dm8-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// 执行 JDBC 查询的函数
async function executeQuery(sql, connectionString) {
  return new Promise((resolve, reject) => {
    const javaCode = `
import java.sql.*;

public class DM8Query {
    public static void main(String[] args) {
        String url = "${connectionString}";
        String sql = args[0];

        try {
            Class.forName("dm.jdbc.driver.DmDriver");
            Connection conn = DriverManager.getConnection(url);
            Statement stmt = conn.createStatement();

            boolean isResultSet = stmt.execute(sql);

            if (isResultSet) {
                ResultSet rs = stmt.getResultSet();
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();

                // 输出列名
                for (int i = 1; i <= columnCount; i++) {
                    System.out.print(metaData.getColumnName(i));
                    if (i < columnCount) System.out.print("\\t");
                }
                System.out.println();

                // 输出数据
                while (rs.next()) {
                    for (int i = 1; i <= columnCount; i++) {
                        System.out.print(rs.getString(i));
                        if (i < columnCount) System.out.print("\\t");
                    }
                    System.out.println();
                }
                rs.close();
            } else {
                int updateCount = stmt.getUpdateCount();
                System.out.println("Rows affected: " + updateCount);
            }

            stmt.close();
            conn.close();
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
`;

    // 写入临时 Java 文件
    const tempJavaFile = join(__dirname, 'temp', 'DM8Query.java');
    fs.mkdirSync(join(__dirname, 'temp'), { recursive: true });
    fs.writeFileSync(tempJavaFile, javaCode);

    // 编译并运行
    const javac = spawn('javac', ['-cp', config.jdbcDriverPath || '.', tempJavaFile]);

    javac.on('close', (code) => {
      if (code !== 0) {
        reject(new Error('Failed to compile Java code'));
        return;
      }

      const java = spawn('java', [
        '-cp',
        `${join(__dirname, 'temp')};${config.jdbcDriverPath || '.'}`,
        'DM8Query',
        sql
      ]);

      let output = '';
      let error = '';

      java.stdout.on('data', (data) => {
        output += data.toString();
      });

      java.stderr.on('data', (data) => {
        error += data.toString();
      });

      java.on('close', (code) => {
        if (code !== 0) {
          reject(new Error(error || 'Query execution failed'));
        } else {
          resolve(output);
        }
      });
    });
  });
}

// 列出可用工具
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "query",
        description: "Execute a SQL query on DM8 database",
        inputSchema: {
          type: "object",
          properties: {
            sql: {
              type: "string",
              description: "SQL query to execute",
            },
          },
          required: ["sql"],
        },
      },
      {
        name: "list_tables",
        description: "List all tables in the database",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "describe_table",
        description: "Get the structure of a specific table",
        inputSchema: {
          type: "object",
          properties: {
            table_name: {
              type: "string",
              description: "Name of the table to describe",
            },
          },
          required: ["table_name"],
        },
      },
    ],
  };
});

// 处理工具调用
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (!config.connectionString) {
    return {
      content: [
        {
          type: "text",
          text: "Error: Database connection not configured. Please edit config.json",
        },
      ],
    };
  }

  try {
    let result;

    switch (name) {
      case "query":
        result = await executeQuery(args.sql, config.connectionString);
        break;

      case "list_tables":
        result = await executeQuery(
          "SELECT TABLE_NAME FROM USER_TABLES",
          config.connectionString
        );
        break;

      case "describe_table":
        result = await executeQuery(
          `SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE FROM USER_TAB_COLUMNS WHERE TABLE_NAME = '${args.table_name.toUpperCase()}'`,
          config.connectionString
        );
        break;

      default:
        return {
          content: [
            {
              type: "text",
              text: `Unknown tool: ${name}`,
            },
          ],
          isError: true,
        };
    }

    return {
      content: [
        {
          type: "text",
          text: result,
        },
      ],
    };
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// 启动服务器
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("DM8 MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
