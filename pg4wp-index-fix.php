<?php
/**
 * Plugin Name: PG4WP Index Fix
 * Description: Fix ADD INDEX syntax MySQL → PostgreSQL untuk PG4WP
 * Auto-loaded via mu-plugins
 */

add_filter('query', function($sql) {
    // Fix ALTER TABLE ADD INDEX / ADD KEY
    if (preg_match(
        '/ALTER\s+TABLE\s+`?(\w+)`?\s+ADD\s+(?:KEY|INDEX)\s+`?(\w+)`?\s*\((.+?)\)/i',
        $sql, $m
    )) {
        $table = $m[1];
        $index = $m[2];
        $cols  = preg_replace('/`/', '"', $m[3]);
        $cols  = preg_replace('/\(\d+\)/', '', $cols); // hapus prefix length
        return "CREATE INDEX IF NOT EXISTS {$index} ON {$table} ({$cols})";
    }

    // Fix CREATE TABLE jika tabel sudah ada
    if (preg_match('/CREATE\s+TABLE\s+(?!IF NOT EXISTS)/i', $sql)) {
        $sql = preg_replace(
            '/CREATE\s+TABLE\s+`?(\w+)`?/i',
            'CREATE TABLE IF NOT EXISTS $1',
            $sql
        );
    }

    return $sql;
}, 1);