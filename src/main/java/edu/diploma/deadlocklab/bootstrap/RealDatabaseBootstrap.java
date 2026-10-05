package edu.diploma.deadlocklab.bootstrap;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

public class RealDatabaseBootstrap {
    private static final String LAB_SCHEMA = prop("lab.schema", "deadlock_lab");
    private static final String MSSQL_DATABASE = prop("lab.mssql.database", "deadlock_lab");
    private static final String MSSQL_SCHEMA = prop("lab.mssql.schema", "lab");
    private static final String MSSQL_USER = prop("lab.mssql.user", "deadlock_lab_user");
    private static final String MSSQL_PASSWORD = prop("lab.mssql.password", "deadlock_lab_2026");
    private static final String ORACLE_USER = prop("lab.oracle.user", "DEADLOCK_LAB");
    private static final String ORACLE_PASSWORD = prop("lab.oracle.password", "deadlock_lab_2026");

    public static void main(String[] args) throws Exception {
        String target = args.length == 0 ? "all" : args[0].toLowerCase(Locale.ROOT);
        if ("all".equals(target) || "postgresql".equals(target) || "pg".equals(target)) bootstrapPostgresql();
        if ("all".equals(target) || "mssql".equals(target) || "sqlserver".equals(target)) bootstrapMssql();
        if ("all".equals(target) || "oracle".equals(target)) bootstrapOracle();
    }

    private static void bootstrapPostgresql() throws Exception {
        Class.forName("org.postgresql.Driver");
        String url = prop("lab.pg.admin.url", "jdbc:postgresql://127.0.0.1:5432/ibank?charSet=WIN");
        String user = prop("lab.pg.admin.user", "dev1");
        String password = prop("lab.pg.admin.password", "owner");
        System.out.println("PostgreSQL bootstrap: schema=" + LAB_SCHEMA + ", url=" + url);
        try (Connection connection = DriverManager.getConnection(url, user, password)) {
            execute(connection,
                    "CREATE SCHEMA IF NOT EXISTS " + pgIdent(LAB_SCHEMA) + " AUTHORIZATION " + pgIdent(user),
                    "GRANT USAGE, CREATE ON SCHEMA " + pgIdent(LAB_SCHEMA) + " TO " + pgIdent(user));
        }
    }

    private static void bootstrapMssql() throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String masterUrl = prop("lab.mssql.admin.url", "jdbc:sqlserver://192.168.88.91:1433;databaseName=master;encrypt=false;trustServerCertificate=true");
        String user = prop("lab.mssql.admin.user", "sa");
        String password = prop("lab.mssql.admin.password", "1111");
        System.out.println("MSSQL bootstrap: database=" + MSSQL_DATABASE + ", schema=" + MSSQL_SCHEMA + ", url=" + masterUrl);
        try (Connection connection = DriverManager.getConnection(masterUrl, user, password)) {
            connection.setAutoCommit(true);
            execute(connection,
                    "IF DB_ID(N'" + sqlLiteral(MSSQL_DATABASE) + "') IS NULL CREATE DATABASE " + msIdent(MSSQL_DATABASE),
                    "IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'" + sqlLiteral(MSSQL_USER) + "') "
                            + "CREATE LOGIN " + msIdent(MSSQL_USER) + " WITH PASSWORD = N'" + sqlLiteral(MSSQL_PASSWORD) + "', CHECK_POLICY = OFF");
        }

        String databaseUrl = prop("lab.mssql.database.url", "jdbc:sqlserver://192.168.88.91:1433;databaseName=" + MSSQL_DATABASE + ";encrypt=false;trustServerCertificate=true");
        try (Connection connection = DriverManager.getConnection(databaseUrl, user, password)) {
            connection.setAutoCommit(true);
            execute(connection,
                    "IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'" + sqlLiteral(MSSQL_USER) + "') "
                            + "CREATE USER " + msIdent(MSSQL_USER) + " FOR LOGIN " + msIdent(MSSQL_USER) + " WITH DEFAULT_SCHEMA = " + msIdent(MSSQL_SCHEMA),
                    "IF SCHEMA_ID(N'" + sqlLiteral(MSSQL_SCHEMA) + "') IS NULL EXEC(N'CREATE SCHEMA " + msIdent(MSSQL_SCHEMA).replace("'", "''") + " AUTHORIZATION " + msIdent(MSSQL_USER).replace("'", "''") + "')",
                    "ALTER USER " + msIdent(MSSQL_USER) + " WITH DEFAULT_SCHEMA = " + msIdent(MSSQL_SCHEMA),
                    "GRANT CREATE TABLE TO " + msIdent(MSSQL_USER),
                    "GRANT CREATE VIEW TO " + msIdent(MSSQL_USER),
                    "GRANT CREATE PROCEDURE TO " + msIdent(MSSQL_USER),
                    "GRANT ALTER ON SCHEMA::" + msIdent(MSSQL_SCHEMA) + " TO " + msIdent(MSSQL_USER),
                    "GRANT CONTROL ON SCHEMA::" + msIdent(MSSQL_SCHEMA) + " TO " + msIdent(MSSQL_USER));
        }
    }

    private static void bootstrapOracle() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        String url = prop("lab.oracle.admin.url", "jdbc:oracle:thin:@192.168.88.91:1521/orclpdb");
        String user = prop("lab.oracle.admin.user", "SYSTEM");
        String password = prop("lab.oracle.admin.password", "1111");
        System.out.println("Oracle bootstrap: user/schema=" + ORACLE_USER + ", url=" + url);
        try (Connection connection = DriverManager.getConnection(url, user, password)) {
            if (!oracleUserExists(connection, ORACLE_USER)) {
                execute(connection, "CREATE USER " + oraIdent(ORACLE_USER) + " IDENTIFIED BY \"" + ORACLE_PASSWORD.replace("\"", "\"\"") + "\" DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS");
            }
            execute(connection,
                    "GRANT CREATE SESSION TO " + oraIdent(ORACLE_USER),
                    "GRANT CREATE TABLE TO " + oraIdent(ORACLE_USER),
                    "GRANT CREATE VIEW TO " + oraIdent(ORACLE_USER),
                    "GRANT CREATE SEQUENCE TO " + oraIdent(ORACLE_USER),
                    "GRANT CREATE PROCEDURE TO " + oraIdent(ORACLE_USER),
                    "ALTER USER " + oraIdent(ORACLE_USER) + " QUOTA UNLIMITED ON USERS");
        }
    }

    private static boolean oracleUserExists(Connection connection, String user) throws SQLException {
        try (Statement statement = connection.createStatement();
             ResultSet rs = statement.executeQuery("SELECT COUNT(*) FROM all_users WHERE username = '" + sqlLiteral(user.toUpperCase(Locale.ROOT)) + "'")) {
            rs.next();
            return rs.getInt(1) > 0;
        }
    }

    private static void execute(Connection connection, String... sqls) throws SQLException {
        List<String> commands = Arrays.asList(sqls);
        try (Statement statement = connection.createStatement()) {
            for (String sql : commands) {
                System.out.println("  SQL> " + sql);
                statement.execute(sql);
            }
        }
    }

    private static String prop(String name, String defaultValue) {
        String value = System.getProperty(name);
        if (value != null && !value.trim().isEmpty()) return value.trim();
        String envName = name.toUpperCase(Locale.ROOT).replace('.', '_').replace('-', '_');
        value = System.getenv(envName);
        if (value != null && !value.trim().isEmpty()) return value.trim();
        return defaultValue;
    }

    private static String pgIdent(String value) {
        return '"' + value.replace("\"", "\"\"") + '"';
    }

    private static String msIdent(String value) {
        return '[' + value.replace("]", "]]") + ']';
    }

    private static String oraIdent(String value) {
        return '"' + value.toUpperCase(Locale.ROOT).replace("\"", "\"\"") + '"';
    }

    private static String sqlLiteral(String value) {
        return value.replace("'", "''");
    }
}
