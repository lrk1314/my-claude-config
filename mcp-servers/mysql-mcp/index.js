#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import mysql from 'mysql2/promise';
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
    name: "mysql-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// 创建数据库连接
async function createConnection() {
  if (!config.host || !config.port || !config.user || !config.password) {
    throw new Error('Database connection not configured. Please edit config.json');
  }

  return await mysql.createConnection({
    host: config.host,
    port: config.port,
    user: config.user,
    password: config.password,
    database: config.database,
  });
}

// 执行查询
async function executeQuery(sql) {
  const connection = await createConnection();
  try {
    const [rows, fields] = await connection.execute(sql);

    // 格式化输出
    if (Array.isArray(rows) && rows.length > 0) {
      // 获取列名
      const columns = Object.keys(rows[0]);
      let result = columns.join('\t') + '\n';

      // 添加数据行
      for (const row of rows) {
        const values = columns.map(col => {
          const val = row[col];
          return val === null ? 'NULL' : String(val);
        });
        result += values.join('\t') + '\n';
      }

      return result;
    } else if (typeof rows === 'object' && 'affectedRows' in rows) {
      return `Rows affected: ${rows.affectedRows}`;
    } else {
      return 'Query executed successfully';
    }
  } finally {
    await connection.end();
  }
}

// 列出可用工具
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "query",
        description: "Execute a SQL query on MySQL database",
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

  try {
    let result;

    switch (name) {
      case "query":
        result = await executeQuery(args.sql);
        break;

      case "list_tables":
        const dbName = config.database || 'information_schema';
        result = await executeQuery(
          `SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = '${dbName}' ORDER BY TABLE_NAME`
        );
        break;

      case "describe_table":
        const tableName = args.table_name;
        result = await executeQuery(
          `SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT, EXTRA
           FROM information_schema.COLUMNS
           WHERE TABLE_SCHEMA = '${config.database}' AND TABLE_NAME = '${tableName}'
           ORDER BY ORDINAL_POSITION`
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
  console.error("MySQL MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
