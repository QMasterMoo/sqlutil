-- common psql scripts I want to save

-- generate indexes
select t.schemaname, t.tablename
    , a.attname as columnname
    , concat('create index ix_', t.tablename, '_', a.attname, ' ON ', t.tablename, ' ("',a.attname,'");')
from pg_tables t
inner join pg_class tc ON t.tablename = tc.relname
inner join pg_attribute a on tc.oid = a.attrelid
where tc.relnamespace = 16386--f1stats
and not exists -- all columns not in an index
    (SELECT *
    from pg_index i2
    inner join pg_attribute a2 ON i2.indrelid = tc.oid
        --and unnest(i2.indkey) = a.attnum
        and a2.attnum = any(i2.indkey)
    where i2.indrelid = tc.oid -- tieback to table
    and a2.attnum = a.attnum
    )
and exists -- column name exists in primary key of another table
    (select *
    from pg_index i2
    inner join pg_class ic2 ON i2.indexrelid = ic2.oid
    inner join pg_attribute ia2 ON i2.indrelid = ia2.attrelid
        and ia2.attnum = any(i2.indkey)
    where ic2.relnamespace = 16386
    and ic2.relname like '%pkey'
    and i2.indrelid <> tc.oid
    and ia2.attname = a.attname -- name not num
    )
    
-- todo generate foreign keys where not exists
