PRAGMA foreign_keys = ON;
DROP TABLE IF EXISTS concept;
CREATE TABLE concept( id VARCHAR(255) PRIMARY KEY NOT NULL,
                      name_main varchar(255)  NOT NULL DEFAULT '',
                      definition TEXT,
                      name_mnemonic varchar(255),
                      broader_id VARCHAR(255) DEFAULT NULL,
                      FOREIGN KEY (broader_id) REFERENCES concept(id) ON DELETE SET NULL
);

DROP TABLE IF EXISTS concept_alias;
CREATE TABLE concept_alias( alias_id VARCHAR(255) UNIQUE NOT NULL,
                              concept_id VARCHAR(255) NOT NULL,
                              FOREIGN KEY(concept_id) REFERENCES concept(id) ON DELETE CASCADE
                             );

