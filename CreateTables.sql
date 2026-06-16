CREATE DATABASE IF NOT EXISTS maven_fuzzy_factory;

CREATE USER 'product_analyst'@'localhost' IDENTIFIED BY '<YOUR_PASSWORD>';
GRANT ALL PRIVILEGES ON maven_fuzzy_factory.* TO 'product_analyst'@'localhost';
FLUSH PRIVILEGES;

USE maven_fuzzy_factory;

CREATE TABLE products (
    product_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    product_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (product_id)
);

CREATE TABLE website_sessions (
    website_session_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    user_id INT NOT NULL,
    is_repeat_session INT NOT NULL, 
    utm_source VARCHAR(50),
    utm_campaign VARCHAR(50),
    utm_content VARCHAR(50),
    device_type VARCHAR(25) NOT NULL,
    http_referer VARCHAR(50),
    PRIMARY KEY (website_session_id)
);

CREATE TABLE website_pageviews (
    website_pageview_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    website_session_id INT NOT NULL,
    pageview_url VARCHAR(50) NOT NULL,
    PRIMARY KEY (website_pageview_id),
    FOREIGN KEY (website_session_id) REFERENCES website_sessions(website_session_id)
);

CREATE TABLE orders (
    order_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    website_session_id INT NOT NULL,
    user_id INT NOT NULL,
    primary_product_id INT NOT NULL,
    items_purchased INT NOT NULL,
    price_usd DECIMAL(6,2) NOT NULL,
    cogs_usd DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (website_session_id) REFERENCES website_sessions(website_session_id),
    FOREIGN KEY (primary_product_id) REFERENCES products(product_id)
);

CREATE TABLE order_items (
    order_item_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    is_primary_item INT NOT NULL,
    price_usd DECIMAL(6,2) NOT NULL,
    cogs_usd DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE order_item_refunds (
    order_item_refund_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    order_item_id INT NOT NULL,
    order_id INT NOT NULL,
    refund_amount_usd DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (order_item_refund_id),
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);