--------------------------------------------------------
--  DDL for Package Body SENDMAILJPKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."SENDMAILJPKG" AS
PROCEDURE ParseAttachment(Attachments IN ATTACHMENTS_LIST,
            AttachmentList OUT VARCHAR2) IS AttachmentSeparator CONSTANT VARCHAR2(12) := '///';

BEGIN
-- boolean short-circuit is used here;

IF Attachments IS NOT NULL AND Attachments.COUNT > 0 THEN

AttachmentList := Attachments(Attachments.FIRST);

-- scan the collection if there is more than one element. If there
-- is not, skip the next part for parsing elements 2 and above. If there
-- is, skip the first element since it has been already processed

 IF Attachments.COUNT > 1 THEN
  FOR I IN Attachments.NEXT(Attachments.FIRST) .. Attachments.LAST
  LOOP
   AttachmentList := AttachmentList || AttachmentSeparator || Attachments(I);
         END LOOP;
 ELSE
 -- whe have to terminate the list with the one element with  /// for the java function
  AttachmentList := AttachmentList  || AttachmentSeparator;
 END IF;

ELSE

 AttachmentList:= '';

END IF;

END ParseAttachment;

-- forward declaration;

FUNCTION JSendMail( SMTPServerName IN STRING,
   Sender IN STRING,
   Recipient IN STRING,
   CcRecipient IN STRING,
   BccRecipient IN STRING,
   Subject IN STRING,
   Body IN STRING,
   ErrorMessage OUT STRING,
   Attachments IN STRING) RETURN NUMBER;     -- high-level interface with collections;

FUNCTION SendMail(    SMTPServerName IN STRING,
                      Sender IN STRING,
                      Recipient IN STRING,
                      CcRecipient IN STRING,
                      BccRecipient IN STRING,
                      Subject IN STRING,
                      Body IN STRING,
                      ErrorMessage OUT STRING,
                      Attachments IN ATTACHMENTS_LIST)
                      RETURN NUMBER IS AttachmentList VARCHAR2(4000) := '';

AttachmentTypeList VARCHAR2(2000) := '';

BEGIN

 ParseAttachment(Attachments,
   AttachmentList);

 RETURN JSendMail(SMTPServerName,
                  Sender,
                  Recipient,
                  CcRecipient,
                  BccRecipient,
                  Subject,
                  Body,
                  ErrorMessage,
                  AttachmentList);
                  END SendMail;      -- JSendMail's body is the java function SendMail.Send();
                     -- thus, no PL/SQL implementation is needed;
FUNCTION JSendMail( SMTPServerName IN STRING,
   Sender IN STRING,
   Recipient IN STRING,
   CcRecipient IN STRING,
   BccRecipient IN STRING,
   Subject IN STRING,
   Body IN STRING,
   ErrorMessage OUT STRING,
   Attachments IN STRING) RETURN NUMBER IS LANGUAGE JAVA NAME
    'SendMail.Send(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String[],java.lang.String) return int';
END SendMailJPkg;

/

  GRANT EXECUTE ON "AXIS"."SENDMAILJPKG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."SENDMAILJPKG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."SENDMAILJPKG" TO "PROGRAMADORESCSI";
