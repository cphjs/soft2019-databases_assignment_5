

## Exercise 1

alter table posts add column Comments json default null;

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

```
CREATE TRIGGER after_comments_insert 
    AFTER INSERT ON comments
    FOR EACH ROW 
BEGIN
    CALL denormalizeComments(NEW.PostId);
END
```

## Exercise 3

```
CREATE PROCEDURE createComment(IN p_Id INT, IN p_PostId INT, IN p_Score INT, IN p_Text text, IN p_CreationDate DATETIME, IN p_UserId INT)
BEGIN
    INSERT INTO comments (Id, PostId, Score, Text, CreationDate,UserId) values (p_Id, p_PostId, p_Score, p_Text, p_CreationDate, p_UserId);
    CALL denormalizeComments(p_postId);
END;
```

## Exercise 4
