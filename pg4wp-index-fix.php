<?php
/**
 * Plugin Name: PG4WP Index Fix
 * Description: Intercept ADD INDEX sebelum masuk PG4WP, eksekusi langsung ke PostgreSQL
 */

add_filter('query', function($sql) {
    global $wpdb;

    // Tangkap ALTER TABLE ADD INDEX / ADD KEY
    if (preg_match(
        '/ALTER\s+TABLE\s+`?(\w+)`?\s+ADD\s+(?:KEY|INDEX)\s+`?(\w+)`?\s*\((.+?)\)/i',
        $sql, $m
    )) {
        $table = $m[1];
        $index = $m[2];
        $cols  = preg_replace('/`(\w+)`(\(\d+\))?/', '"$1"', $m[3]);

        // Eksekusi langsung ke PostgreSQL via koneksi native, bypass PG4WP
        $conn = pg_connect(sprintf(
            "host=%s dbname=%s user=%s password=%s",
            DB_HOST, DB_NAME, DB_USER, DB_PASSWORD
        ));

        if ($conn) {
            pg_query($conn, "CREATE INDEX IF NOT EXISTS \"{$index}\" ON \"{$table}\" ({$cols})");
            pg_close($conn);
        }

        // Return query dummy yang PG4WP bisa handle (SELECT tidak merusak apapun)
        return "SELECT 1";
    }

    // Fix CREATE TABLE agar tidak error jika sudah ada
    if (preg_match('/CREATE\s+TABLE\s+(?!IF\s+NOT\s+EXISTS\s)/i', $sql)) {
        $sql = preg_replace(
            '/CREATE\s+TABLE\s+`?(\w+)`?/i',
            'CREATE TABLE IF NOT EXISTS "$1"',
            $sql
        );
    }

    return $sql;
}, 1);