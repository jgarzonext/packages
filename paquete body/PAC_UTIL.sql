--------------------------------------------------------
--  DDL for Package Body PAC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_UTIL" AS
    /******************************************************************************
      NOMBRE:       PAC_UTIL
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1. Creación de package
       2.0       17/03/2009  RSC              2. Análisis adaptación productos indexados
       2.1       07/04/2009  RSC              2. Análisis adaptación productos indexados
       3.0       03/08/2019  JMJRR            3. IAXIS-4994 Se agrega funcion fu_split
   ******************************************************************************/

   /**********************************************************************************************
    Validar que la condició es a TRUE, aleshores NO és un error, omple el codi i missatge d'error i fa un raise
    Paràmetres entrada:
       pNoHayError : TRUE és OK, FALSE si és un error
       pCodError : Codi d'error a utilitzar si pHayError és a FALSE
       oCodError : Codi a tornar si hi ha un error
       oMsgError : Text a tornar si hi ha un error
   **********************************************************************************************/
   FUNCTION validar(
      pnohayerror IN BOOLEAN,
      pcoderror IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN BOOLEAN IS
   BEGIN
      RETURN validar(pnohayerror, pcoderror, f_idiomauser, ocoderror, omsgerror);
   END validar;

   /***************************************************************************************
    Validar que el codi és 0, sinó, és el número d'error
    Paràmetres entrada:
       pCodError : 0 si OK, altrament el número d'error
       oCodError : Codi d'error a utilitzar si pHayError és a FALSE
       oMsgError : Text si hi ha un error
   **********************************************************************************************/
   FUNCTION validar(pcoderror IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
      RETURN BOOLEAN IS
   BEGIN
      RETURN validar(pcoderror, f_idiomauser, ocoderror, omsgerror);
   END validar;

   /**********************************************************************************************
    Validar que la condició es a TRUE, aleshores NO és un error, omple el codi i missatge d'error i fa un raise
    Paràmetres entrada:
       pNoHayError : TRUE és OK, FALSE si és un error
       pCodError : Codi d'error a utilitzar si pHayError és a FALSE
       Pcidioma_user : Idioma de l'usuari
       oCodError : Codi a tornar si hi ha un error
       oMsgError : Text a tornar si hi ha un error
   **********************************************************************************************/
   FUNCTION validar(
      pnohayerror IN BOOLEAN,
      pcoderror IN NUMBER,
      pcidioma_user IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN BOOLEAN IS
   BEGIN
      IF NOT pnohayerror THEN
         ocoderror := pcoderror;
         omsgerror := f_literal(ocoderror, pcidioma_user);
      ELSE
         ocoderror := 0;
         omsgerror := NULL;
      END IF;

      RETURN pnohayerror;
   END validar;

   /***************************************************************************************
    Validar que el codi és 0, sinó, és el número d'error
    Paràmetres entrada:
       pCodError : 0 si OK, altrament el número d'error
       Pcidioma_user : Idioma de l'usuari
       oCodError : Codi d'error a utilitzar si pHayError és a FALSE
       oMsgError : Text si hi ha un error
   **********************************************************************************************/
   FUNCTION validar(
      pcoderror IN NUMBER,
      pcidioma_user IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN BOOLEAN IS
   BEGIN
      IF pcoderror <> 0 THEN
         ocoderror := pcoderror;
         omsgerror := f_literal(ocoderror, pcidioma_user);
      ELSE
         ocoderror := 0;
         omsgerror := NULL;
      END IF;

      RETURN(pcoderror = 0);
   END validar;

   /***************************************************************************************
    Función para realizar splits sobre una cadena.
    Params:
       PC$Chaine: Cadena sobre la que queremos realizar el split.
       PN$Pos: Token de la cadena que queremos extraer.
       PC$Sep: Separador de la cadena por el que queremos hacer SPLIT.
   ****************************************************************************************/
   FUNCTION splitt(pc$chaine IN VARCHAR2, pn$pos IN PLS_INTEGER, pc$sep IN VARCHAR2 DEFAULT ',')
      RETURN VARCHAR2 IS
      lc$chaine      VARCHAR2(32767) := pc$sep || pc$chaine;
      li$i           PLS_INTEGER;
      li$i2          PLS_INTEGER;
   BEGIN
      li$i := INSTR(lc$chaine, pc$sep, 1, pn$pos);

      IF li$i > 0 THEN
         li$i2 := INSTR(lc$chaine, pc$sep, 1, pn$pos + 1);

         IF li$i2 = 0 THEN
            li$i2 := LENGTH(lc$chaine) + 1;
         END IF;

         RETURN(SUBSTR(lc$chaine, li$i + 1, li$i2 - li$i - 1));
      ELSE
         RETURN NULL;
      END IF;
   END splitt;

   /***************************************************************************************
    Obtener la ruta y el nombre de archivo a partir de una ruta entera.
    Params:
       in ppath: Ruta de entrada.
       out pruta: Ruta directorio.
       out pfilename: Nombre del archivo.
   ****************************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC - Análisis adaptación productos indexados
   FUNCTION f_path_filename(ppath IN VARCHAR2, pruta OUT VARCHAR2, pfilename OUT VARCHAR2)
      RETURN NUMBER IS
      vtest          VARCHAR2(2000);
      i              NUMBER := 1;
      v_dirname      VARCHAR2(2000);
      v_filename     VARCHAR2(2000);
      v_fi           NUMBER := 0;
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      vseparador     VARCHAR2(1);
   -- Fin Bug 9031
   BEGIN
      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      vseparador := SUBSTR(ppath, 1, 1);
      -- Fin Bug 9031
      vtest := REPLACE(ppath, '/', '#');
      vtest := REPLACE(vtest, '\', '#');

      WHILE v_fi = 0 LOOP
         IF pac_util.splitt(vtest, i + 1, '#') IS NULL
            AND i <> 1 THEN
            -- El i <> 1 nos protege de paths como \\srv-desa\Interfases_Delta
            v_filename := pac_util.splitt(vtest, i, '#');
            v_fi := 1;
         ELSE
            -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
            -- Utilizamos separador
            v_dirname := v_dirname || pac_util.splitt(vtest, i, '#') || vseparador;
         -- Fin Bug 9031
         END IF;

         i := i + 1;
      END LOOP;

      pruta := v_dirname;
      pfilename := v_filename;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_path_filename;
   --ini IAXIS-4994
   FUNCTION fu_split(
  p_string_in     IN VARCHAR2, 
  p_delim_in      IN  VARCHAR2)
    RETURN t_array
    IS
    /**************************************************************************
        NOMBRE:         fu_split
        TIPO:           Funcion
        PROPOSITO:      Funcion que devuelve una tabla o array con cada uno de los 
                        elementos de una cadena de texto separados por un caracter delimitador
        CREADO POR:     Inforcol-JMJRR
    
    
        PARAMETROS DE ENTRADA:
        Nombre                      Tipo            Descripcion
        -------------------         --------        -----------------------
        p_string_in                 VARCHAR         Cadena a separar
        p_delim_in                  VARCHAR         Caracter delimitador
    
        PARAMETROS DE SALIDA:
        Nombre                      Tipo        Descripcion
        ---------                   --------    -----------------------------------
        t_array                     TYPE        Array/Tabla con los elementos
    
        EXCEPCIONES
        Nombre          Descripcion
        ---------       -------------------------------------------------------
    
        REVISIONES:
        Version     Fecha       Autor                   Descripcion
        ---------   ----------  --------------------    -----------------------
        1.0         10/08/2016  Inforcol - LMCT         Creacion y documentacion de funcion
    
    ***************************************************************************/
      ----------------------------------------------------------------------------
      --  SECCION VARCHAR
      ----------------------------------------------------------------------------
        v_list       VARCHAR2(32767) := p_string_in;
        
      ----------------------------------------------------------------------------
      --  SECCION NUMBER
      ----------------------------------------------------------------------------
        n_contador   NUMBER :=0;
        
      ----------------------------------------------------------------------------
      --  SECCION PLS_INTEGER
      ----------------------------------------------------------------------------
        i_idx        PLS_INTEGER;
    
      ----------------------------------------------------------------------------
      --  SECCION TYPE PERSONALIZADOS
      ----------------------------------------------------------------------------
        strings    t_array;
    
    BEGIN
    
       LOOP
          i_idx := INSTR(v_list, p_delim_in);
          IF i_idx > 0 THEN
              strings(n_contador) := SUBSTR(v_list,1, i_idx-1);
              v_list := SUBSTR(v_list,i_idx+LENGTH(p_delim_in));
          ELSIF (i_idx = 0 AND v_list IS NOT NULL) THEN
              strings(n_contador) := v_list;
             EXIT;
          ELSE
             EXIT;
          END IF;
          n_contador := n_contador+1;
       END LOOP;
    
      RETURN strings;
    
    END fu_split;
    --fin IAXIS-4994
END pac_util;

/

  GRANT EXECUTE ON "AXIS"."PAC_UTIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL" TO "PROGRAMADORESCSI";
