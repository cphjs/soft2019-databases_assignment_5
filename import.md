
# Functional way to import XML


Run MySQL shell(or whatever client you're using) with the `--local-infile`

Turn on the import functionality on the server with:

```
set global local_infile = 1;
```

Now it should be possible to import data using following queries. You might need to change the file paths to absolute ones.

```
load xml local infile 'Badges.xml' into table badges rows identified by '<row>';
load xml local infile 'Comments.xml' into table comments rows identified by '<row>';
load xml local infile 'PostHistory.xml' into table post_history rows identified by '<row>';
load xml local infile 'PostLinks.xml' into table post_links rows identified by '<row>';
load xml local infile 'Posts.xml' into table posts rows identified by '<row>';
load xml local infile 'Tags.xml' into table tags rows identified by '<row>';
load xml local infile 'Users.xml' into table users rows identified by '<row>';
load xml local infile 'Votes.xml' into table votes rows identified by '<row>';
```


These queries might fix some import warning but are unnecessary in general.
```
alter table posts change Title Title varchar(256) null;
alter table posts change FavoriteCount FavoriteCount int null, change AnswerCount AnswerCount int null;
```

## Windows

The above mentioned commands may not be enough to import data on Windows(go figure, eh?). It seems windows MySQL server also has `secure_file_priv`. Since it is a read-only variable it cannot be changed with just `SET secure_file_priv = null;`. Therefore it is easier to just move the files to the folder that variable is pointing. You can see the folder by executing `show global variables like '%secure_file_priv%';`.