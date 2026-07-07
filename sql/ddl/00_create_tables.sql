CREATE TABLE plans (
    plan_name       VARCHAR(50) PRIMARY KEY,
    price           NUMERIC(10,2) NOT NULL
);

CREATE TABLE customer_profile (
    id                      SERIAL PRIMARY KEY,
    company_name            VARCHAR(255),
    country                 VARCHAR(100),
    acquisition_channel     VARCHAR(50),
    company_size_segment    VARCHAR(50)
);

CREATE TABLE payment_profile (
    customer_id     INTEGER PRIMARY KEY REFERENCES customer_profile(id),
    current_plan    VARCHAR(50) REFERENCES plans(plan_name),
    payment_method  VARCHAR(50),
    is_auto_renew   BOOLEAN
);

CREATE TABLE transaction (
    transaction_id  SERIAL PRIMARY KEY,
    customer_id     INTEGER REFERENCES customer_profile(id),
    plan_name       VARCHAR(50) REFERENCES plans(plan_name),
    transaction_date DATE,
    is_auto_renew   BOOLEAN
);

ALTER TABLE transaction ADD COLUMN event_type VARCHAR(50);
ALTER TABLE transaction ADD COLUMN previous_plan VARCHAR(50);

TRUNCATE TABLE transaction;