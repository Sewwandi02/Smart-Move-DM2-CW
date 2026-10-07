BEGIN
    FOR auth_role IN (
        SELECT 'ADMIN' AS role_name FROM dual
        UNION ALL
        SELECT 'DRIVER' AS role_name FROM dual
        UNION ALL
        SELECT 'PASSENGER' AS role_name FROM dual
    ) LOOP
        INSERT INTO Role (role_name)
        SELECT auth_role.role_name
        FROM dual
        WHERE NOT EXISTS (
            SELECT 1
            FROM Role existing_role
            WHERE UPPER(existing_role.role_name) = auth_role.role_name
        );
    END LOOP;

    COMMIT;
END;
/
