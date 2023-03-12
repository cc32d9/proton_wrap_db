
CREATE TABLE WRAP_CURRENT_ADDRESSES
(
  idx               BIGINT PRIMARY KEY,
  account           VARCHAR(12) NOT NULL,
  coin              TEXT NOT NULL,
  wallet            TEXT NOT NULL,
  address           TEXT NOT NULL,
  address_hash      TEXT NOT NULL
);

CREATE INDEX WRAP_CURRENT_ADDRESSES_I01 ON WRAP_CURRENT_ADDRESSES(account, coin);
CREATE INDEX WRAP_CURRENT_ADDRESSES_I02 ON WRAP_CURRENT_ADDRESSES(address);


CREATE TABLE WRAP_CURRENT_ADDRESSES2
(
  idx               BIGINT PRIMARY KEY,
  account           VARCHAR(12) NOT NULL,
  chain             TEXT NOT NULL,
  address           TEXT NOT NULL,
  address_hash      TEXT NOT NULL
);

CREATE INDEX WRAP_CURRENT_ADDRESSES2_I01 ON WRAP_CURRENT_ADDRESSES2(account, chain);
CREATE INDEX WRAP_CURRENT_ADDRESSES2_I02 ON WRAP_CURRENT_ADDRESSES2(address);


CREATE TABLE WRAP_CURRENT_WRAPS
(
  idx               BIGINT PRIMARY KEY,
  proton_account    VARCHAR(12) NOT NULL,
  contract          VARCHAR(13) NOT NULL,
  currency          VARCHAR(8) NOT NULL,
  amount            DECIMAL(22,0) NOT NULL,
  decimals          SMALLINT NOT NULL,
  txid              TEXT NOT NULL,
  coin              TEXT NOT NULL,
  wallet            TEXT NOT NULL,
  deposit_address   TEXT NOT NULL,
  status            TEXT NOT NULL,
  confirmations     INT NOT NULL,
  finish_txid       VARCHAR(64) NOT NULL,
  wrap_hash         VARCHAR(64) NOT NULL
);

CREATE INDEX WRAP_CURRENT_WRAPS_I01 ON WRAP_CURRENT_WRAPS(proton_account, coin);
CREATE INDEX WRAP_CURRENT_WRAPS_I02 ON WRAP_CURRENT_WRAPS(txid);
CREATE INDEX WRAP_CURRENT_WRAPS_I03 ON WRAP_CURRENT_WRAPS(deposit_address);


CREATE TABLE WRAP_CURRENT_WRAPS2
(
  idx               BIGINT PRIMARY KEY,
  proton_account    VARCHAR(12) NOT NULL,
  contract          VARCHAR(13) NOT NULL,
  currency          VARCHAR(8) NOT NULL,
  amount            DECIMAL(22,0) NOT NULL,
  decimals          SMALLINT NOT NULL,
  id                DECIMAL(22,0) NOT NULL,
  txid              TEXT NOT NULL,
  chain             TEXT NOT NULL,
  deposit_address   TEXT NOT NULL,
  status            TEXT NOT NULL,
  confirmations     INT NOT NULL,
  finish_txid       VARCHAR(64) NOT NULL,
  wrap_hash         VARCHAR(64) NOT NULL
);

CREATE INDEX WRAP_CURRENT_WRAPS2_I01 ON WRAP_CURRENT_WRAPS2(proton_account, chain);
CREATE INDEX WRAP_CURRENT_WRAPS2_I02 ON WRAP_CURRENT_WRAPS2(txid);
CREATE INDEX WRAP_CURRENT_WRAPS2_I03 ON WRAP_CURRENT_WRAPS2(deposit_address);




