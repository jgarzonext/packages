--------------------------------------------------------
--  DDL for Package PAC_INT_ONLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INT_ONLINE" IS
/******************************************************************************
   NOMBRE:       PAC_INT_ONLINE

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creaci¿n del package.
   2.0        03/08/2010   PFA                2. 15631: AXISLISTENER con trazas - Parte PL
   3.0        12/08/2010   PFA                3. 13893: CEM800 - INTERFICIES: Recuperar PAIS per defecte via parametritzaci¿ de BD
   4.0        26/08/2010   SRA                4. 14365: CRT002 - Gestion de personas
   5.0        23/10/2013   FPG                5. 28263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
******************************************************************************/

   ----variable que contendr¿ la secuencia de la interfaz
   vsinterf       NUMBER;
   ----variable que contendr¿ el posicionamiento devuelto por la interfaz con BM
   ----  cuando la decisi¿n de seguir con otra llamada o no la tiene el usuario
   ----  Estos casos son los que en la tabla int_servicios_formato tienen el campo
   ----  rpposicionamiento informado a 0.
   ----  En el caso que el usuario decida seguir, desde el formulario debe pasarse
   ----  a la llamada a la interfaz, como valor del par¿metro de entrada posicionamiento
   ----  el valor devuelto en la ¿ltima interfaz.
   vposicionamiento VARCHAR2(15);
   ----variable que contendr¿ la url enviada
   vurl           VARCHAR2(2000);   --int_hostb2b.url%type;
   ----variable que contendr¿ el protocolo
   vprot          int_hostb2b.protocolo%TYPE;
   ----variable que contendr¿ la respuesta en una variable tipo parser
   vparser        xmlparser.parser;
   --
   verror_peticion_host NUMBER;

   PROCEDURE p_inicializar_sinterf;

   FUNCTION f_obtener_sinterf
      RETURN NUMBER;

   FUNCTION f_obtener_posicionamiento
      RETURN VARCHAR2;

   --s'eliminar¿ de la cap¿alera quan desaparegui pac_xml_mv
   PROCEDURE finalizar_parser(v_parser IN OUT xmlparser.parser);

   FUNCTION f_busca_siguiente_url(purl_ini IN VARCHAR2)
      RETURN VARCHAR2;

   --s'eliminar¿ de la cap¿alera quan desaparegui pac_xml_mv
   PROCEDURE peticion_host(
      pemp IN VARCHAR2,
      p_tipoint IN VARCHAR2,
      p_msg IN VARCHAR2,
      p_msgout IN OUT VARCHAR2);

   FUNCTION f_int_fichero(
      pccompani IN VARCHAR2,
      pnservei IN VARCHAR2,
      purl_ini IN VARCHAR2,
      pnomfitxer IN VARCHAR2,
      ptexto IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_int(
      pemp IN VARCHAR2,
      psinterf IN NUMBER,
      pnservei IN VARCHAR2,
      plinia_ida IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_recuperar_error(
      pemp IN VARCHAR2,
      psinterf IN NUMBER,
      pcidioma IN NUMBER,
      pnresultado OUT VARCHAR2,
      ptresultado OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_obtener_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalemp IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_obtener_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalaxis IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_buscar_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalemp IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_buscar_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalaxis IN VARCHAR2)
      RETURN VARCHAR2;

   /*
     Dada una descripcio de pais, devuelve el codigo del pais
     Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia
   */
   FUNCTION f_buscar_pais(ptpais IN VARCHAR2)
      RETURN VARCHAR2;

     /*
     Dada una codigo iso  de pais, devuelve el codigo del pais
     Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia
   */
   FUNCTION f_buscar_pais_iso(pcodiso IN VARCHAR2)
      RETURN VARCHAR2;

   /*
     Dada una descripcion de una provincia, devuelve el codigo de la provincia
     Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia.
     Opcional el codigo de pais
   */
   FUNCTION f_buscar_provincia(ptprovincia IN VARCHAR2, pcpais IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   /*
     Dada una descripcio de un profesi¿n devuelve el c¿digo de la profesi¿n.
     Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia.
   */
   FUNCTION f_buscar_profesion(ptprofesion IN VARCHAR2)
      RETURN VARCHAR2;

   /*
     Dado una descripcio de una poblaci¿n  y opcionalmente el codigo dela provincia a la que pertenece,
     devuelve el codigo de la poblaci¿n.Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia.
   */
   FUNCTION f_buscar_poblacion(ptpoblacion IN VARCHAR2, pcprovincia IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   /*
     Dado una empresa y una maquina fisica devuelve el codigo de terminal
   */
   FUNCTION f_obtener_terminal(
      pcempres IN terminales.cempres%TYPE,
      pcmaqfisi IN terminales.cmaqfisi%TYPE)
      RETURN terminales.cterminal%TYPE;

   /*
   Dado una descripcion de agente recupera su codigo.
   */
   FUNCTION f_obtiene_codigo_agente(p_nombre_completo IN VARCHAR2)
      RETURN agentes.cagente%TYPE;

   /*
     Grabamos el log del mensaje recibido a HOST, dado un sinterf
   */
   FUNCTION f_log_hostin(psinterf IN NUMBER, ptmeninhost IN CLOB)
      RETURN NUMBER;

   /*
     Grabamos el log del mensaje enviado a HOST, dado un sinterf
   */
   FUNCTION f_log_hostout(psinterf IN NUMBER, ptmenouthost IN CLOB)
      RETURN NUMBER;

   /*
     Dado una abreviatura, nos recupere el codigo del tipo de via -- mantis 8600
   */
   FUNCTION f_obtiene_tipo_via(ptsiglas IN tipos_via.tsiglas%TYPE)
      RETURN NUMBER;

   /*
    Crea una nueva poblacion para la provincia indicada O A¿ADE UN NUEVO COD POSTAL SI NO EXISTE.-- mantis 8600.
   */
   FUNCTION f_crear_poblacion(
      p_nombre_poblacion VARCHAR2,
      p_cod_provincia NUMBER,
      p_codigo_postal VARCHAR2,
      p_cod_poblacion OUT NUMBER)
      RETURN NUMBER;

   /*
    Dado un tipo cta Host devuelve el codigo interno de AXIS
   */
   FUNCTION f_obtener_tipocuenta(p_ctipcuentahost IN VARCHAR2)
      RETURN NUMBER;

   /*
    Da de alta un registro en CTACATEGORIA_ORDEN.
    Devuelve la columna CTIPCUENTA creada
   */
   FUNCTION f_crear_tipocuenta(p_ctipcuentahost IN VARCHAR2)
      RETURN NUMBER;

--Bug 13893 - PFA - 12/08/2010
   FUNCTION f_buscar_pais_defecto
      RETURN VARCHAR2;

/*
 Retorna el c¿digo del pais por defecto, informado en PARINSTALCION = PAIS_DEF.
 Puede que retorna nulo.
*/
--Fi Bug 13893 - PFA - 12/08/2010

   --Bug 15631 - PFA - 03/08/2010
   /*
    Produce trazas de log en BBDD para investigar incidencias
    Bug 28263 FPG - 23/10/2013: cambiar par¿metro psinterf a IN OUT
   */
   FUNCTION f_inicializar_log_listener(
      pcinterf IN VARCHAR,
      ptmenout IN CLOB,
      psinterf IN OUT NUMBER)
      RETURN NUMBER;

--Fi Bug 15631 - PFA - 03/08/2010

   -- Bug 14365 - 26/08/2010 - SRA - funci¿n que devuelve un cursor con todas las equivalencias entre c¿digos origen de la empresa
-- y su c¿digo equivalente en AXIS
   FUNCTION f_obtener_valores_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN sys_refcursor;

-- Bug 14365 - 26/08/2010 - SRA - funci¿n que devuelve un cursor con todas las equivalencias entre c¿digos origen en AXIS
-- y su c¿digo equivalente en la empresa
   FUNCTION f_obtener_valores_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN sys_refcursor;

   /*
     Grabamos el log del mensaje recibido a HOST, dado un sinterf
   */
   FUNCTION f_log_proceso(psinterf IN NUMBER, psxml IN number, pxmlrespuesta IN CLOB)
      RETURN NUMBER;

  function recuperaTagErrorRespGenerWS(xml_clob clob) return varchar2;
END pac_int_online;

/

  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE" TO "PROGRAMADORESCSI";
