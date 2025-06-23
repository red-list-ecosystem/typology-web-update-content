### Database

The database includes three tables for content: `efg_ecological_traits`, `efg_key_ecological_drivers` and `efg_distribution`. They all have the same structure:

```sql
Column    |            Type             | Nullable | Comment
--------------+-----------------------------+-----------+----------
code         | character varying(10)       | not null | efg code, e.g. `T1.1`
language     | character varying(10)       | not null | `en` for English, etc
description  | text                        |          | text
contributors | text[]                      |          | array of authors
editors      | text[]                      |          | array of editors
version      | character varying(10)       | not null | version as `v1.0`, etc
update       | timestamp without time zone |          |
```

Index is constructed by unique combinations of code, language and version, `code` is used as a foreign key from table `functional_groups`, which includes the name, alternative shortname and brief description.

// TODO: Document additional tables in the SQL database
