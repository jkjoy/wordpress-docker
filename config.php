<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'database_name_here' );

/** Database username */
define( 'DB_USER', 'username_here' );

/** Database password */
define( 'DB_PASSWORD', 'password_here' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

/**#@-*/
// 读取环境变量并设置默认值
$wp_home = getenv('WP_HOME') ?: 'http://localhost';
$wp_siteurl = getenv('WP_SITEURL') ?: 'http://localhost';
$force_ssl_login = getenv('FORCE_SSL_LOGIN') ?: 'true';
$force_ssl_admin = getenv('FORCE_SSL_ADMIN') ?: 'true';
$https_enabled = getenv('HTTPS_ENABLED') ?: 'true';

// 获取服务器 IP 地址和域名
$server_ip = $_SERVER['SERVER_ADDR'];
$server_name = $_SERVER['SERVER_NAME'];

// 如果环境变量没有设置，尝试使用服务器 IP 地址或域名
if ($wp_home === 'http://localhost') {
    if (!empty($server_name)) {
        $wp_home = 'http://' . $server_name;
        $wp_siteurl = 'http://' . $server_name;
    } elseif (!empty($server_ip)) {
        $wp_home = 'http://' . $server_ip;
        $wp_siteurl = 'http://' . $server_ip;
    }
}

// 设置 WP_HOME 和 WP_SITEURL
define('WP_HOME', $wp_home);
define('WP_SITEURL', $wp_siteurl);

// 设置 SSL 相关配置
if ($https_enabled === 'true') {
    $_SERVER['HTTPS'] = 'on';
    if ($force_ssl_login === 'true') {
        define('FORCE_SSL_LOGIN', true);
    }
    if ($force_ssl_admin === 'true') {
        define('FORCE_SSL_ADMIN', true);
    }
}

// 其他配置...
/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/../' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
