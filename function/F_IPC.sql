--------------------------------------------------------
--  DDL for Function F_IPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IPC" (
   pmes IN NUMBER,
   panyo IN NUMBER,
   p_ctipo NUMBER DEFAULT 1,
   p_campo NUMBER DEFAULT 1)
   RETURN NUMBER IS
   -- función que nos devuelve el ipc para un año y un mes , si no encuentra
   -- ningun registro devuelve un NULL

   -- BUG 0021638 - 08/03/2012 - JMF: Añadir tipo y campo.
   vpipc          NUMBER;
BEGIN
   SELECT DECODE(p_campo, 2, nfactor, pipc)
     INTO vpipc
     FROM ipc
    WHERE nanyo = panyo
      AND nmes = pmes
      AND ctipo = p_ctipo;

   RETURN vpipc;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END f_ipc;

/

  GRANT EXECUTE ON "AXIS"."F_IPC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IPC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IPC" TO "PROGRAMADORESCSI";
