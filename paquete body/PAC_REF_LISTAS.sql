--------------------------------------------------------
--  DDL for Package Body PAC_REF_LISTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_LISTAS" 
AS
FUNCTION f_forpag_producto(psproduc IN NUMBER, pcidioma IN NUMBER, pmodo IN NUMBER DEFAULT 1)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con las formas de pago permitidas en un producto.
 . Parámetro de entrada pmodo = 1. Alta de pólizas
                                2. Suplementos
******************************************************************************************/

   v_cursor     cursor_TYPE;
BEGIN

   open v_cursor for
        SELECT cforpag, tatribu
        FROM forpagpro f, detvalores d
        WHERE (cramo, cmodali, ctipseg, ccolect) = (SELECT cramo, cmodali, ctipseg, ccolect
                                                    FROM productos
                                                      WHERE sproduc = psproduc)
          AND d.cidioma = pcidioma
          AND d.cvalor = 17
          AND d.catribu = f.cforpag
        UNION
        SELECT catribu, tatribu
        FROM detvalores
        WHERE cidioma = pcidioma
          AND cvalor = 17
          AND catribu = 0
          AND pmodo = 2;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'pac_ref_lista.f_forpag_producto',NULL, 'parametros: psproduc='||psproduc||
                    ' pcidioma='||pcidioma||' pmodo='||pmodo,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_forpag_producto;
FUNCTION f_forpagren_producto(psproduc IN NUMBER, pcidioma IN NUMBER, pcduracion IN NUMBER)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con las formas de pago permitidas en un producto.
 . Parámetro de entrada pmodo = 1. Alta de pólizas
                                2. Suplementos
******************************************************************************************/

   v_cursor     cursor_TYPE;
   vcon         NUMBER;
BEGIN
   select count(*) into vcon
   from durforpagren d
   where sproduc = psproduc
     and cduraci = pcduracion
     and ctipopag = 2;

   IF vcon <> 0 THEN
    open v_cursor for
        SELECT cforpag, tatribu
        FROM durforpagren f, detvalores d
        WHERE f.sproduc = psproduc
          AND d.cidioma = pcidioma
          AND d.cvalor = 17
          AND f.cduraci = pcduracion
          AND d.catribu = f.cforpag;
   ELSE
    open v_cursor for
       SELECT cforpag, tatribu
       FROM forpagren f, detvalores d
       WHERE f.sproduc = psproduc
         AND d.cidioma = pcidioma
         AND d.cvalor = 17
         AND d.catribu = f.cforpag;
   END IF;
   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
	    p_tab_error(f_sysdate,  getUSER,  'pub_lista.f_forpagren_producto',NULL, 'parametros: psproduc='||psproduc||
                    ' pcidioma='||pcidioma,SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_forpagren_producto;


FUNCTION f_perctasacion_producto(psproduc IN NUMBER, pcidioma IN NUMBER,pfecefec IN DATE)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con los % tasación del producto

******************************************************************************************/

   v_cursor     cursor_TYPE;
BEGIN

   open v_cursor for
        select b.CRESPUE codi  , b.TRESPUE literal
                from
                PREGUNPRO a, RESPUESTAS b
                where
                a.SPRODUC=psproduc
                and a.CPREGUN=101
                and b.CIDIOMA=pcidioma
                and b.CPREGUN=a.CPREGUN;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'pac_ref_lista.f_forpag_producto',NULL, 'parametros: psproduc='||psproduc||
                    ' pcidioma='||pcidioma||' pfecefec='||TO_CHAR(pfecefec,'DD/MM/YYYY'),
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_perctasacion_producto;

FUNCTION f_duraciones_producto(psproduc IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con las duraciones permitidas en un producto
******************************************************************************************/
    v_cursor     cursor_TYPE;
BEGIN

   open v_cursor for
      SELECT ndurper, tatribu
      FROM durperiodoprod du, detvalores d
      WHERE  sproduc = psproduc
      AND d.cidioma = pcidioma
      AND d.cvalor = 20
      AND catribu = 1;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_duraciones_producto',NULL, 'parametros: psproduc='||psproduc||
                    ' pcidioma='||pcidioma,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_duraciones_producto;

FUNCTION f_clau_benef_producto(psproduc IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con las clausulas de beneficiario permitidas en un producto
******************************************************************************************/
    v_cursor     cursor_TYPE;
BEGIN

   open v_cursor for
      SELECT c.sclaben, tclaben
      FROM clausuben c, claubenpro cp
      WHERE  cp.sproduc = psproduc
      AND c.cidioma = pcidioma
      AND c.sclaben = cp.sclaben
      ORDER BY norden;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_clau_benef_producto',NULL, 'parametros: psproduc='||psproduc||
                    ' pcidioma='||pcidioma,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_clau_benef_producto;

FUNCTION f_duraciones_renova(psseguro IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con las duraciones permitidas en un producto
******************************************************************************************/
    v_cursor     cursor_TYPE;
    v_sproduc    NUMBER;
BEGIN

   Select sproduc
   into v_sproduc
   From seguros
   Where sseguro = psseguro;

   open v_cursor for
      SELECT ndurper, tatribu
      FROM durperiodoprod du, detvalores d
      WHERE  sproduc = v_sproduc
      AND d.cidioma = pcidioma
      AND d.cvalor = 20
      AND catribu = 1
      AND pac_val_comu.f_valida_duracion_renova(psseguro, ndurper) = 0;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_duraciones_renova',NULL, 'parametros: psseguro='||psseguro||
                    ' pcidioma='||pcidioma,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_duraciones_renova;

/******************************************************************************************
 Llista amb els motius d'anulació per productes des de TF
******************************************************************************************/
FUNCTION f_motivos_anulacion_tf(psproduc IN PRODUCTOS.SPRODUC%TYPE, pcidioma IN IDIOMAS.CIDIOMA%TYPE)
RETURN SYS_REFCURSOR IS
    v_cursor     SYS_REFCURSOR;
BEGIN

   open v_cursor for
      SELECT cmotmov, s.tmotmov
      FROM      prodmotmov p
           JOIN motmovseg s
           USING (cmotmov)
      WHERE     p.sproduc = psproduc
            AND s.cidioma = pcidioma
            -- cmovseg = 3            -- Anulació. No cal doncs és inclòs en p.cmotmov = 306
            -- AND p.cmotmov = 306       -- Només TF
            AND F_PARMOTMOV(cmotmov, 'ANUL_EFECTO', psproduc ) = 1  -- Només TF : cmotmov = 306, ...
      ORDER BY p.norden;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_motivos_anulacion_tf',1, 'parametros: psproduc='||psproduc||
                    ' pcidioma='||pcidioma,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END;

/**********************************************************************************************
 Llista amb tots els rebuts d'una pòlissa.
 Paràmetres entrada:
    pSSeguro : Identificador de l'assegurança
    pTipo    : Tipus de rebut    (0-Pendents, 1-Cobrats, 2-Anul·lats, 10-Qualsevol tipus de rebut)
    pCIdioma : Codi de l'idioma  (1- Català, 2-Espanyol)
 Torna un cursor amb:
    Nrecibo : número rebut
    Fefecto : Data f'efecte del rebut
    ItotalR : Import del rebut
    Cestrec : Codi d'estat del rebut (0-Pendents, 1-Cobrats, 2-Anul·lats)
    Testrec : Descripció de l'estat
**********************************************************************************************/
FUNCTION f_recibos_poliza(  psseguro IN RECIBOS.SSEGURO%TYPE,
                            ptipo    IN RECIBOS.CTIPREC%TYPE,
                            pcidioma IN IDIOMAS.CIDIOMA%TYPE
                         )
RETURN SYS_REFCURSOR IS
    v_cursor     SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT a.*, t.tatribu testrec
    FROM
    (
        SELECT nrecibo, r.fefecto, dr.itotalr, F_CESTREC( nrecibo, NULL) cestrec
          FROM      recibos r
               JOIN vdetrecibos dr
               USING ( nrecibo )
          WHERE     r.sseguro = psseguro
     ) a
     JOIN  detvalores t
     ON ( a.cestrec = t.catribu )
     WHERE t.cvalor = 1     -- Estats dels rebuts
           AND t.cidioma = pcidioma
           AND ( a.cestrec = ptipo OR ptipo = 10 )
     ORDER BY a.fefecto DESC, a.nrecibo
     ;
    RETURN v_cursor;
EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_recibos_poliza',1,
                    'parametros: psseguro='||psseguro||
                               ' ptipo='||ptipo||
                               ' pcidioma='||pcidioma,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END;


FUNCTION f_forpagprest_producto(psproduc IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con las formas de pago permitidas en un producto.
******************************************************************************************/

   v_cursor     cursor_TYPE;
   vcprprod     NUMBER;
BEGIN

   Begin
     Select cprprod
     Into vcprprod
     From productos
     Where sproduc = psproduc;
   Exception
     When Others Then
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_forpagprest_producto',NULL, 'parametros: psproduc='||psproduc||
                    ' pcidioma_user='||pcidioma_user,
                      SQLERRM);
        RETURN v_cursor;
   End;

   open v_cursor for
    SELECT   catribu, tatribu
    FROM    DETVALORES
    WHERE    cidioma = pcidioma_user
        AND cvalor = 205
        AND catribu = 0
        AND vcprprod = 0
    UNION
    SELECT   catribu, tatribu
    FROM    DETVALORES
    WHERE    cidioma = pcidioma_user
        AND cvalor = 205
        AND catribu = 1
        AND vcprprod = 1
    UNION
    SELECT   catribu, tatribu
    FROM    DETVALORES
    WHERE    cidioma = pcidioma_user
        AND cvalor = 205
        AND catribu in (0,1)
        AND vcprprod = 3
    ORDER BY 1;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_forpagprest_producto',NULL, 'parametros: psproduc='||psproduc||
                    ' pcidioma_user='||pcidioma_user,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_forpagprest_producto;


  --  MSR 2/8/2007
  --  Torna els productes per una agrupació / ram
  --
  --  Paràmetres
  --    pcAgrpro   Opcional
  --    pcRamo     Opcional
  --

  FUNCTION f_Productos (pcAgrpro IN SEGUROS.CAGRPRO%TYPE, pcRamo IN RAMOS.CRAMO%TYPE) RETURN cursor_TYPE IS
    v_Cursor cursor_type;
  BEGIN
    OPEN v_Cursor FOR
            SELECT p.sproduc,
                   t.ttitulo,
                   cramo,
                   cmodali
              FROM       productos p
                    JOIN titulopro t USING  ( ctipseg, cramo, cmodali, ccolect )
              WHERE     t.cidioma = F_IDIOMAUSER
                    AND ( p.cagrpro = pcAgrpro  OR pcAgrpro IS NULL )
                    AND ( cramo = pcRamo OR pcRamo IS NULL )
              ORDER BY  cramo, cmodali, ctipseg, ccolect
        ;
    RETURN v_cursor;
  EXCEPTION
    WHEN OTHERS THEN
       p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas.f_Productos', 1, ' pcAgrpro='||pcAgrpro||' pcRamo='||pcRamo, SQLERRM);
       CLOSE v_cursor;
       RETURN v_cursor;
  END;


FUNCTION f_motivos_sinies_aho(psseguro IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con los motivos de siniestro permitidos en una póliza de ahorro dependiendo de la parametrización
 del producto y del número de asegurados vigentes en una variable de tipo ref cursor.
 . Parámetro de entrada:  psseguro = Identificador de la póliza
                          pcidioma = Código de idioma del usuario
******************************************************************************************/
   v_cursor     cursor_TYPE;
   num_aseg_vigentes  NUMBER;
BEGIN

  -- Buscar el número de asegurados vigentes en la póliza
  Select count(1)
  Into num_aseg_vigentes
  From asegurados
  Where sseguro = psseguro
   And ffecfin is null;

   open v_cursor for
    SELECT distinct to_char(D.CMOTSIN) cod, D.TMOTSIN des
    FROM DESMOTSINI d, SEGUROS s, PRODCAUMOTSIN p, GARANSEG g
    WHERE
      p.cramo = d.cramo and
      p.cmotsin = d.cmotsin and
      p.ccausin = d.ccausin and
      p.sproduc = s.sproduc and
      p.cgarant = g.cgarant and
      g.sseguro = s.sseguro and
      d.CCAUSIN = 1 AND
      D.CIDIOMA = pcidioma AND
      S.SSEGURO = psseguro AND
      g.ffinefe is null and
      (
       (num_aseg_vigentes = 2 and d.cmotsin <> 0) -- Si la póliza tiene 2 asegurados vigentes, sólo motivo Fallecimiento de 1 titular (cmotsin = 4)
       or
       (num_aseg_vigentes < 2 and d.cmotsin <> 4) -- Si la póliza tiene un titular vigente, solo motivo de fallecimiento (cmotsin = 0)
      )
    ORDER BY D.CMOTSIN;
   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_motivos_sinies_aho',NULL, 'parametros: psseguro='||psseguro||
                    ' pcidioma='||pcidioma,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_motivos_sinies_aho;

FUNCTION f_asegurados(psseguro IN NUMBER)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con los asegurados vigentes en una póliza
 . Parámetro de entrada:  psseguro = Identificador de la póliza
******************************************************************************************/
   v_cursor     cursor_TYPE;
BEGIN

   open v_cursor for
      Select norden, f_nombre(sperson, 1,s.cagente)
      From asegurados a,seguros s
      Where a.sseguro = psseguro
        And a.ffecfin is null
        and s.SSEGURO = a.SSEGURO
      Order by norden;

   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_asegurados',NULL, 'parametros: psseguro='||psseguro,
                      SQLERRM);
        close v_cursor;
        RETURN v_cursor;
END f_asegurados;

FUNCTION f_get_datos_poliza_basics(psseguro IN NUMBER, cidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
RETURN cursor_TYPE IS
/******************************************************************************************
 Lista con los datos basicos de la póliza
 . Parámetro de entrada:  psseguro = Identificador de la póliza
                          cidioma = idioma
******************************************************************************************/
   CURSOR cur_aseg IS
      SELECT ROWNUM, sperson, cdomici
      FROM asegurados
      WHERE sseguro = psseguro;

   sperson1   NUMBER;
   cdomici1 NUMBER;
   sperson2   NUMBER;
   cdomici2 NUMBER;

   --Retorno
   v_cursor     cursor_TYPE;
BEGIN

   FOR regs IN cur_aseg LOOP
    IF regs.ROWNUM = 1 THEN
      sperson1 :=  regs.sperson;
      cdomici1 := regs.cdomici;
    ELSIF regs.ROWNUM = 2 THEN
      sperson2 :=  regs.sperson;
      cdomici2 := regs.cdomici;
    END IF;
   END LOOP;

   open v_cursor for
       select sseguro, sproduc, cramo, cmodali, ctipseg, ccolect, npoliza,
              ncertif, cidioma, csituac, fefecto, cbancar, sperson1, cdomici1, sperson2, cdomici2
       from seguros
       where sseguro = psseguro;
   RETURN v_cursor;

EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Listas..f_get_datos_poliza_basics',NULL, 'parametros: psseguro='||psseguro||
                                          ' cidioma='||cidioma,SQLERRM);
        ocoderror := 108190;  -- Error General
        omsgerror := f_literal(ocoderror, cidioma);
        close v_cursor;
        RETURN v_cursor;
END f_get_datos_poliza_basics;

END Pac_Ref_Listas;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_LISTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LISTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LISTAS" TO "PROGRAMADORESCSI";
