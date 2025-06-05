CREATE DATABASE IF NOT EXISTS blogdb;
USE blogdb;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    group_type ENUM('g_admin', 'g_user', 'g_author', 'g_mod') NOT NULL
);

CREATE TABLE IF NOT EXISTS blogs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    publish_status BOOLEAN NOT NULL,
    categories VARCHAR(255),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

