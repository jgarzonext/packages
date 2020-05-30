--------------------------------------------------------
--  DDL for Function F_ESTIMPAGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTIMPAGO" (pnrecibo IN NUMBER, pfecha IN DATE)
   RETURN NUMBER IS
/******************************************************************************
   NOMBRE:       F_ESTIMPAGO
   PROPÓSITO:    Para saber si un recibo está impagado, según la tabla de impagados
                 manuales MOVRECIBOI (ALN) a una fecha ,
                 (0-No es impago, 1-Sí es impago bancario, 2-Sí es impago manual)
   REVISIONES:

   Ver       Fecha       Autor  Descripción
   --------  ----------  -----  ----------------------------------------------
   1.0       -           -      1. Creación de package
   2.0       05/12/2011  JGR    2. 0020037: Parametrización de Devoluciones
******************************************************************************/
   vobject        VARCHAR2(500) := 'F_ESTIMPAGO';
   vparam         VARCHAR2(500)
                            := 'parámetros - pnrecibo: ' || pnrecibo || ', pfecha: ' || pfecha;
   vpasexec       NUMBER(5) := 1;
   xsel           VARCHAR2(2000);

   TYPE t_cursor IS REF CURSOR;

   c_rec          t_cursor;
   n_num          NUMBER(1) := 0;
   v_fec          VARCHAR2(8);
BEGIN
   IF NVL(pnrecibo, 0) = 0 THEN
      RETURN 0;
   END IF;

   vpasexec := 1;
   -- Bug 0012679 - 18/02/2010 - JMF: CEM - Treure la taula MOVRECIBOI
   v_fec := TO_CHAR(pfecha, 'ddmmyyyy');
   vpasexec := 2;
   xsel := 'SELECT 1 numrec ' || '  FROM MOVRECIBO m '
           || ' WHERE m.cestant IN (3, 1) AND m.cestrec = 0 ' || '   AND to_date('''
           || v_fec   --> 20037 - Añadir cestant 3
                   || ''',''ddmmyyyy'') >= m.fmovini ' || '   AND (to_date(''' || v_fec
           || ''',''ddmmyyyy'') < m.fmovfin or
	       m.fmovfin is null) ' || '	  AND m.nrecibo = ' || pnrecibo;
   vpasexec := 3;

   OPEN c_rec FOR xsel;

   vpasexec := 4;

   FETCH c_rec
    INTO n_num;

   vpasexec := 5;

   IF c_rec%NOTFOUND THEN
      n_num := 0;
   END IF;

   vpasexec := 6;

   CLOSE c_rec;

   vpasexec := 7;
   RETURN n_num;
EXCEPTION
   WHEN OTHERS THEN
      IF c_rec%ISOPEN THEN
         CLOSE c_rec;
      END IF;

      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                  xsel || ' ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 0;
END f_estimpago;

/

  GRANT EXECUTE ON "AXIS"."F_ESTIMPAGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTIMPAGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTIMPAGO" TO "PROGRAMADORESCSI";
