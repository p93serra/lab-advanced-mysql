/* 
Advanced MySQL
*/

USE publications;

-- CHALLENGE 1

-- STEP 1

SELECT * FROM sales;
SELECT * FROM titleauthor;
SELECT * FROM titles;

SELECT 
    ta.title_id AS `Title ID`,
    ta.au_id AS `Author ID`,
    ROUND(t.advance * ta.royaltyper / 100, 2) AS `Advance`,
    ROUND(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,
            2) AS `Sales Royalty`
FROM
    titleauthor ta
LEFT JOIN titles t ON t.title_id = ta.title_id
LEFT JOIN sales s ON s.title_id = ta.title_id;
    
-- STEP 2
SELECT 
    `Title ID`,
    `Author ID`,
    `Advance`,
    SUM(`Sales Royalty`) AS `Aggregated Sales Royalty`
FROM
    (SELECT 
        ta.title_id AS `Title ID`,
            ta.au_id AS `Author ID`,
            ROUND(t.advance * ta.royaltyper / 100, 2) AS `Advance`,
            ROUND(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 2) AS `Sales Royalty`
    FROM
        titleauthor ta
    LEFT JOIN titles t ON t.title_id = ta.title_id
    LEFT JOIN sales s ON s.title_id = ta.title_id) r_p_a
GROUP BY `Title ID` , `Author ID`;

-- STEP 3
SELECT 
    `Author ID`,
    SUM(`Advance` + `Aggregated Sales Royalty`) AS `Total Profits`
FROM
    (SELECT 
        `Title ID`,
            `Author ID`,
            `Advance`,
            SUM(`Sales Royalty`) AS `Aggregated Sales Royalty`
    FROM
        (SELECT 
        ta.title_id AS `Title ID`,
            ta.au_id AS `Author ID`,
            ROUND(t.advance * ta.royaltyper / 100, 2) AS `Advance`,
            ROUND(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 2) AS `Sales Royalty`
    FROM
        titleauthor ta
    INNER JOIN titles t ON t.title_id = ta.title_id
    INNER JOIN sales s ON s.title_id = ta.title_id) r_p_a
    GROUP BY `Title ID` , `Author ID`) a_r_p_a
GROUP BY `Author ID`
ORDER BY `Total Profits` DESC
LIMIT 3;
	
-- CHALLENGE 2
DROP TABLE IF EXISTS r_p_a;
DROP TABLE IF EXISTS a_r_p_a;

CREATE TEMPORARY TABLE r_p_a
SELECT 
    ta.title_id AS `Title ID`,
    ta.au_id AS `Author ID`,
    ROUND(t.advance * ta.royaltyper / 100, 2) AS `Advance`,
    ROUND(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,
            2) AS `Sales Royalty`
FROM
    titleauthor ta
LEFT JOIN titles t ON t.title_id = ta.title_id
LEFT JOIN sales s ON s.title_id = ta.title_id;

CREATE TEMPORARY TABLE a_r_p_a
SELECT 
    `Title ID`,
    `Author ID`,
    `Advance`,
    SUM(`Sales Royalty`) AS `Aggregated Sales Royalty`
FROM
	r_p_a
GROUP BY `Title ID` , `Author ID`, `Advance`;    

SELECT 
    `Author ID`,
    SUM(`Advance` + `Aggregated Sales Royalty`) AS `Total Profits`
FROM
	a_r_p_a
GROUP BY `Author ID`
ORDER BY `Total Profits` DESC
LIMIT 3;

-- CHALLENGE 3
DROP TABLE IF EXISTS most_profiting_authors;
CREATE TABLE most_profiting_authors
SELECT 
    `Author ID` AS au_id,
    SUM(`Advance` + `Aggregated Sales Royalty`) AS profits
FROM
	a_r_p_a
GROUP BY `Author ID`
ORDER BY profits DESC
LIMIT 3;

SELECT * FROM most_profiting_authors;