UPDATE LOOKUP_VALUE SET LOOKUP_NAME='Language-Icelandic' WHERE LOOKUP_ID=(SELECT LOOKUP_ID FROM LANGUAGE WHERE LANG_NAME='Icelandic');
UPDATE LOOKUP_VALUE SET LOOKUP_NAME='Language-Spanish' WHERE LOOKUP_ID=(SELECT LOOKUP_ID FROM LANGUAGE WHERE LANG_NAME='Spanish');
UPDATE LOOKUP_VALUE SET LOOKUP_NAME='Language-French' WHERE LOOKUP_ID=(SELECT LOOKUP_ID FROM LANGUAGE WHERE LANG_NAME='French');


UPDATE DATABASE_VERSION SET DATABASE_VERSION = 177 WHERE DATABASE_VERSION = 176;