
import java.sql.*;

public class DM8Query {
    public static void main(String[] args) {
        String url = "jdbc:dm://47.104.129.85:5236?schema=DEVICE_DB&ssl=true&sslMode=2&user=DEVICE_DB&password=Borsche@123!";
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
                    if (i < columnCount) System.out.print("\t");
                }
                System.out.println();

                // 输出数据
                while (rs.next()) {
                    for (int i = 1; i <= columnCount; i++) {
                        System.out.print(rs.getString(i));
                        if (i < columnCount) System.out.print("\t");
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
