
# Exercises 

- [Assignment and review requirements](https://github.com/datsoftlyngby/soft2019spring-databases/blob/master/assignments/assignment5.md)
- [Material](https://github.com/datsoftlyngby/soft2019spring-databases/blob/master/lecture_notes/05-StoredProceduresAndJSON.ipynb)
- [Potential help on importing](import.md)

## Exercise 1

> Write a stored procedure denormalizeComments(postID) that moves all comments for a post (the parameter) into a json array on the post.

```
alter table posts add column Comments json default null;
```

```
CREATE PROCEDURE denormalizeComments(IN p_postId INT)
BEGIN
    UPDATE posts SET Comments = (
        select JSON_ARRAYAGG(JSON_OBJECT('id', Id, 'score', Score, 'text', Text, 'creationDate', CreationDate, 'userId', userId)) 
        from comments 
        where PostId = p_postId
    ) 
    WHERE Id = p_postId;
END;
```


## Exercise 2

> Create a trigger such that new adding new comments to a post triggers an insertion of that comment in the json array from exercise 1.

```
CREATE TRIGGER after_comments_insert 
    AFTER INSERT ON comments
    FOR EACH ROW 
BEGIN
    CALL denormalizeComments(NEW.PostId);
END
```

## Exercise 3

> Rather than using a trigger, create a stored procedure to add a comment to a post - adding it both to the comment table and the json array

```
CREATE PROCEDURE createComment(IN p_Id INT, IN p_PostId INT, IN p_Score INT, IN p_Text text, IN p_CreationDate DATETIME, IN p_UserId INT)
BEGIN
    INSERT INTO comments (Id, PostId, Score, Text, CreationDate,UserId) values (p_Id, p_PostId, p_Score, p_Text, p_CreationDate, p_UserId);
    CALL denormalizeComments(p_postId);
END;
```

## Exercise 4

> Make a materialized view that has json objects with questions and its answeres, but no comments. Both the question and each of the answers must have the display name of the user, the text body, and the score.

Table to store the "material view"
``` 
CREATE TABLE IF NOT EXISTS questions_with_answers_json (
    PostId INT NOT NULL,
    Data JSON NOT NULL,
    PRIMARY KEY(PostId)
);
```

The view that contains data in the format we want
```
CREATE VIEW questions_with_answers_json_view AS
SELECT 
    posts.id,
    JSON_OBJECT(
        'id', posts.id, 
        'Title', posts.Title, 
        'user', users.DisplayName, 
        'body', posts.Body,
        'score', (
            (SELECT COUNT(Id) FROM votes WHERE PostId = posts.Id AND VoteTypeId = 2)
            - 
            (SELECT COUNT(Id) FROM votes WHERE PostId = posts.Id AND VoteTypeId = 3)
        ),
        'answers', (
            SELECT 
                JSON_ARRAYAGG(JSON_OBJECT(
                    'body', Body, 
                    'user', u2.DisplayName,
                    'score', (
                        (SELECT COUNT(Id) FROM votes WHERE PostId = p2.Id AND VoteTypeId = 2)
                        - 
                        (SELECT COUNT(Id) FROM votes WHERE PostId = p2.Id AND VoteTypeId = 3)
                    )
                ))
            FROM posts p2 
            JOIN users u2 ON u2.Id = p2.OwnerUserId
            WHERE p2.ParentId = posts.Id
        )
    )
FROM posts
JOIN users ON users.Id = posts.OwnerUserId
WHERE posts.ParentId IS NULL;
```

Procedure to update materialized view. Yes. It does delete the whole table every time and repopulate which takes more time than reasonable*. But I _really_ don't want to implement an incremental one.

\* 30 seconds on my (not very good) machine with the coffee stack exchange database
```
CREATE PROCEDURE recomputeQuestionsWithAnswersJson()
BEGIN
    TRUNCATE questions_with_answers_json;
    INSERT INTO questions_with_answers_json SELECT * FROM questions_with_answers_json_view;
END;
```

A trigger to update the materialized view before every minute:
```
CREATE EVENT recompute_questions_with_answers_json_every_minute
  ON SCHEDULE EVERY 1 MINUTE
  DO CALL recomputeQuestionsWithAnswersJson()
```

## Exercise 5

> Using the materialized view from exercise 4, create a stored procedure with one parameter keyword, which returns all posts where the keyword appears at least once, and where at least two comments mention the keyword as well.

This only finds the rows where the question body contains the keyword, aka the first part of the exercise. I did not find a _good_ way to count the number of occurences of a substring in MySQL.

```
CREATE PROCEDURE findQuestionsWithAnswersWithKeyword(IN keyword VARCHAR(255))
BEGIN
    SELECT * 
    FROM questions_with_answers_json 
    WHERE JSON_EXTRACT(data, '$.body') LIKE CONCAT('%', keyword, '%');
END;
```