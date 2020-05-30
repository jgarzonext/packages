--------------------------------------------------------
--  DDL for Package PAC_REF_LISTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_LISTAS" AUTHID CURRENT_USER IS
-- Llista Modificacions
--   MSR 2007/06/01   Afegir funció F_MOTIMOS_ANULACION_TF
--   MSR 2007/06/01   Afegir funció F_RECIBOS_POLIZA
--   JRH 2007/10/25   Afegir funció f_perctasacion_producto
/**********************************************************************************************
  Package público para proporcionar listas de valores con código y descripción

**********************************************************************************************/
--  v_lista                  ob_lista;
--  v_t_lista                  t_lista := t_lista();

  type cursor_TYPE is ref cursor;

FUNCTION f_forpag_producto(psproduc IN NUMBER, pcidioma IN NUMBER, pmodo IN NUMBER DEFAULT 1)
RETURN cursor_TYPE;

FUNCTION f_forpagren_producto(psproduc IN NUMBER, pcidioma IN NUMBER, pcduracion IN NUMBER)
RETURN cursor_TYPE;

FUNCTION f_duraciones_producto(psproduc IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE;

FUNCTION f_clau_benef_producto(psproduc IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE;

FUNCTION f_duraciones_renova(psseguro IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE;


FUNCTION f_perctasacion_producto(psproduc IN NUMBER, pcidioma IN NUMBER,pfecefec IN DATE)
RETURN cursor_TYPE;

/**********************************************************************************************
 Llista amb els motius d'anulació per productes des de TF
**********************************************************************************************/
FUNCTION f_motivos_anulacion_tf(psproduc IN PRODUCTOS.SPRODUC%TYPE, pcidioma IN IDIOMAS.CIDIOMA%TYPE)
RETURN SYS_REFCURSOR;

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
RETURN SYS_REFCURSOR;

FUNCTION f_forpagprest_producto(psproduc IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser)
RETURN cursor_TYPE;

  --  MSR 2/8/2007
  --  Torna els productes per una agrupació / ram
  --
  --  Paràmetres
  --    pcAgrpro   Opcional
  --    pcRamo     Opcional
  --

FUNCTION f_Productos (pcAgrpro IN SEGUROS.CAGRPRO%TYPE, pcRamo IN RAMOS.CRAMO%TYPE) RETURN cursor_TYPE;

FUNCTION f_motivos_sinies_aho(psseguro IN NUMBER, pcidioma IN NUMBER)
RETURN cursor_TYPE;

FUNCTION f_asegurados(psseguro IN NUMBER)
RETURN cursor_TYPE;

FUNCTION f_get_datos_poliza_basics(psseguro IN NUMBER, cidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
RETURN cursor_TYPE;

END Pac_Ref_Listas;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_LISTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LISTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LISTAS" TO "PROGRAMADORESCSI";
