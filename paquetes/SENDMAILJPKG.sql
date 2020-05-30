--------------------------------------------------------
--  DDL for Package SENDMAILJPKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."SENDMAILJPKG" AS
    -- EOL is used to separate text line in the message body;
    EOL CONSTANT STRING(2) := CHR(13) || CHR(10);
    TYPE ATTACHMENTS_LIST IS       TABLE OF VARCHAR2(4000);
    -- high-level interface with collections;
    FUNCTION SendMail( SMTPServerName IN STRING,
       Sender IN STRING,
       Recipient IN STRING,
       CcRecipient IN STRING DEFAULT '',
       BccRecipient IN STRING DEFAULT '',
       Subject IN STRING DEFAULT '',
       Body IN STRING DEFAULT '',
       ErrorMessage OUT STRING,
       Attachments IN ATTACHMENTS_LIST DEFAULT NULL)
    RETURN NUMBER;
END SendMailJPkg;

 
 

/

  GRANT EXECUTE ON "AXIS"."SENDMAILJPKG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."SENDMAILJPKG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."SENDMAILJPKG" TO "PROGRAMADORESCSI";
