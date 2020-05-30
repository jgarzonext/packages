create or replace FUNCTION f_calcula_fcontable(
/******************************************************************************
   NOMBRE:       f_calcula_fcontable
   PROPÓSITO:  Función que analiza si es emision o anulacion de vigencias futuras y asigna la fechacontable correspondiente

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/10/2019   SGM              1. AXIS 5330 FECHAS PARA RECIBOS
******************************************************************************/
   pnrecibo IN NUMBER,
   pcmotmov IN NUMBER,
   fmovini  IN DATE,
   pfcontab OUT DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
   vsseguro recibos.sseguro%TYPE;
   vnmovimi recibos.nmovimi%TYPE;
   vfefecto movseguro.fefecto%TYPE;
BEGIN
    BEGIN
      SELECT sseguro,nmovimi
        INTO vsseguro,vnmovimi
        FROM recibos
       WHERE nrecibo = pnrecibo;
    EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
    END;
    
    BEGIN
      SELECT fefecto
        INTO vfefecto
        FROM movseguro
       WHERE sseguro = vsseguro
         AND nmovimi = vnmovimi;
    EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
    END;    
    IF ((pcmotmov = 100)  OR (pcmotmov = 666)) AND (vfefecto > f_sysdate) THEN
        pfcontab := vfefecto; 
    ELSIF (pcmotmov = 321) THEN--IAXIS-6222 Fechacontable para cancelaciones por impago
        pfcontab := f_sysdate;         
    ELSE
        pfcontab:=fmovini;    
    END IF;

   RETURN 0;
END f_calcula_fcontable;