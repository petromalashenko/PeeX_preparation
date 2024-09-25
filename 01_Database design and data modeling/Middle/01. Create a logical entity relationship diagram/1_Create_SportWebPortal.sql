-- DROP DATABASE SportWebPortal;
CREATE DATABASE SportWebPortal;
GO
USE SportWebPortal;
GO
CREATE TABLE dbo.Leagues (
    LeagueID INT PRIMARY KEY,
    LeagueName VARCHAR(255) NOT NULL
);
GO
CREATE TABLE dbo.Teams (
    TeamID INT PRIMARY KEY,
    TeamName VARCHAR(255) NOT NULL,
    LeagueID INT,
    FOREIGN KEY (LeagueID) REFERENCES Leagues(LeagueID)
);
GO
CREATE TABLE dbo.Games (
    GameID INT PRIMARY KEY,
    GameDate DATE NOT NULL,
    HomeTeamID INT,
    AwayTeamID INT,
    FOREIGN KEY (HomeTeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (AwayTeamID) REFERENCES Teams(TeamID)
);
GO
CREATE TABLE dbo.Events (
    EventID INT PRIMARY KEY,
    GameID INT,
    EventType VARCHAR(255),
    EventDescription TEXT,
    PlayerID INT,
    FOREIGN KEY (GameID) REFERENCES Games(GameID)
);
GO
CREATE TABLE dbo.Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(255) UNIQUE NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL
);
GO
CREATE TABLE dbo.Articles (
    ArticleID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Content TEXT NOT NULL,
    PublishDate DATE NOT NULL,
    TeamID INT,
    LeagueID INT,
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (LeagueID) REFERENCES Leagues(LeagueID)
);
GO
CREATE TABLE dbo.ArticleViews (
    ViewID INT PRIMARY KEY,
    ArticleID INT,
    UserID INT,
    ViewDate DATE NOT NULL,
    FOREIGN KEY (ArticleID) REFERENCES Articles(ArticleID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO
CREATE TABLE dbo.Comments (
    CommentID INT PRIMARY KEY,
    ArticleID INT,
    UserID INT,
    CommentText TEXT NOT NULL,
    CommentDate DATE NOT NULL,
    FOREIGN KEY (ArticleID) REFERENCES Articles(ArticleID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO
CREATE TABLE dbo.Advertisements (
    AdID INT PRIMARY KEY,
    AdContent TEXT NOT NULL,
    TeamID INT,
    LeagueID INT,
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (LeagueID) REFERENCES Leagues(LeagueID)
);
GO
CREATE TABLE dbo.Media (
    MediaID INT PRIMARY KEY,
    MediaType VARCHAR(50) NOT NULL,
    MediaURL TEXT NOT NULL,
    ArticleID INT,
    TeamID INT,
    LeagueID INT,
    GameID INT,
    AdID INT,
    FOREIGN KEY (ArticleID) REFERENCES Articles(ArticleID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (LeagueID) REFERENCES Leagues(LeagueID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID),
    FOREIGN KEY (AdID) REFERENCES Advertisements(AdID)
);
GO
CREATE TABLE dbo.GameTeams (
    GameID INT,
    TeamID INT,
    PRIMARY KEY (GameID, TeamID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
GO