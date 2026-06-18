<?php
// Bootstrap WordPress minimally
if (!defined('ABSPATH')) {
    require_once dirname(__FILE__) . '/wp/wp-blog-header.php';
}

header('Content-Type: text/plain');

echo "=== Auth Debug ===\n\n";
echo "HTTP_AUTHORIZATION: " . ($_SERVER['HTTP_AUTHORIZATION'] ?? 'NOT_SET') . "\n";
echo "REQUEST_URI: " . ($_SERVER['REQUEST_URI'] ?? 'NOT_SET') . "\n\n";

// Check the current user
$current_user = wp_get_current_user();
echo "Current user before validation: " . ($current_user->ID ? $current_user->user_login : 'none') . "\n";

// Manually validate application password
$user = wp_validate_application_password(null);
echo "wp_validate_application_password returned: " . var_export($user, true) . "\n";

if ($user) {
    echo "Validated user: " . $user->user_login . " (ID: " . $user->ID . ")\n";
}

$current_user_after = wp_get_current_user();
echo "Current user after validation: " . ($current_user_after->ID ? $current_user_after->user_login : 'none') . "\n";
