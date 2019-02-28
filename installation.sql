load xml local infile '/work/soft2019spring-databases/assignment_5/Badges.xml' into table badges rows identified by '<row>';
load xml local infile '/work/soft2019spring-databases/assignment_5/Comments.xml' into table comments rows identified by '<row>';
load xml local infile '/work/soft2019spring-databases/assignment_5/PostHistory.xml' into table post_history rows identified by '<row>';
load xml local infile '/work/soft2019spring-databases/assignment_5/PostLinks.xml' into table post_links rows identified by '<row>';
load xml local infile '/work/soft2019spring-databases/assignment_5/Posts.xml' into table posts rows identified by '<row>';
load xml local infile '/work/soft2019spring-databases/assignment_5/Tags.xml' into table tags rows identified by '<row>';
load xml local infile '/work/soft2019spring-databases/assignment_5/Users.xml' into table users rows identified by '<row>';
load xml local infile '/work/soft2019spring-databases/assignment_5/Votes.xml' into table votes rows identified by '<row>';



alter table posts change Title Title varchar(256) null;
alter table posts change FavoriteCount FavoriteCount int null, change AnswerCount AnswerCount int null;

show variables like '%local_infile%';


set global local_infile = 1;


DROP TABLE IF EXISTS badges;
CREATE TABLE `badges` (
  `Id` int(11) NOT NULL,
  `UserId` int(11) DEFAULT NULL,
  `Name` varchar(50) DEFAULT NULL,
  `Date` datetime DEFAULT NULL,
  `Class` int(11) DEFAULT NULL,
  `TagBased` varchar(24) DEFAULT NULL,
  PRIMARY KEY (`Id`)
);