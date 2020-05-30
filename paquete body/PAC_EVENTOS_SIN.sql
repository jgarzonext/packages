--------------------------------------------------------
--  DDL for Package Body PAC_EVENTOS_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_EVENTOS_SIN" AS
/******************************************************************************
   NOMBRE:    PAC_EVENTOS_SIN
   PROPÓSITO: Funciones para la gestión de los eventos de un siniestro.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/12/2009   AMC               1. Creación del package.
******************************************************************************/

   /*************************************************************************
    Función f_get_eventos
    Recupera los eventos
    param in pcevento  : codigo del evento
    param in ptevento  : texto del evento
    param in pfinicio  : fecha inicio
    param in pffinal   : fecha fin
    param in pcidioma  : codigo del idioma
    param out peventos : lista de eventos
    return             :  0 - ok , 1 - ko.

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_eventos(
      pcevento IN VARCHAR2,
      ptevento IN VARCHAR2,
      pfinicio IN DATE,
      pffinal IN DATE,
      pcidioma IN NUMBER,
      peventos OUT sys_refcursor)
      RETURN NUMBER IS
      num_err        NUMBER;
      squery         VARCHAR2(1000);
      vcursor        sys_refcursor;
   BEGIN
      squery := 'SELECT sce.CEVENTO,sde.TTITEVE,sde.TEVENTO,sce.FINIEVE,sce.FFINEVE'
                || ' FROM sin_codevento sce,sin_desevento sde'
                || ' WHERE sce.cevento = sde.cevento' || ' AND (sce.cevento = ''' || pcevento
                || ''' OR ''' || pcevento || ''' IS NULL)'
                || ' AND (UPPER(sde.tevento) LIKE ''%'' || UPPER(''' || ptevento
                || ''') || ''%'' OR ''' || ptevento || ''' IS NULL)'
                || ' AND (TRUNC(sce.finieve) >= ''' || pfinicio || ''' OR ''' || pfinicio
                || ''' IS NULL)' || ' AND (TRUNC(sce.ffineve) <= ''' || pffinal || ''' OR '''
                || pffinal || ''' IS NULL)' || ' AND sde.cidioma = ' || pcidioma
                || ' ORDER BY sce.cevento';

      OPEN vcursor FOR squery;

      peventos := vcursor;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_eventos_sin.f_get_eventos', 1,
                     'error no controlado', SQLERRM || ' ' || squery);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN 1;
   END f_get_eventos;

   /*************************************************************************
     Función f_get_desevento
     Devuelve la query a ejecutar
     param in pcevento  : codigo del evento
     param out psquery  : consulta ha ejecutar
     return             :  0 - ok , 1 - ko.

     -- Bug 12211 - 10/12/2009 - AMC
    *************************************************************************/
   FUNCTION f_get_desevento(pcevento IN VARCHAR2, psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      psquery :=
         'select cevento, s.cidioma,(select tidioma from idiomas where cidioma = s.cidioma and cvisible = 1) tidioma,'
         || ' ttiteve, tevento' || ' from sin_desevento s' || ' where cevento =''' || pcevento
         || CHR(39) || ' AND CIDIOMA IN (SELECT CIDIOMA FROM IDIOMAS WHERE CVISIBLE = 1) '
         || ' union' || ' select null ,cidioma,tidioma,null,null' || ' from idiomas id'
         || ' where id.cidioma not in (select cidioma from sin_desevento where cevento ='''
         || pcevento || ''')' || 'and id.cvisible = 1 order by cidioma';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_eventos_sin.f_get_desevento', 1,
                     'error no controlado', SQLERRM || psquery);
         RETURN 1;
   END f_get_desevento;

   /*************************************************************************
     Función f_get_codevento
     Devuelve las fecha de inicio y fin del evento
     param in pcevento       : codigo del evento
     param out pcevento_out  : codigo del evento
     param out pfinieve      : fecha inicio evento
     param out pffineve      : fecha fin evento
     return                  :  0 - ok , 1 - ko.

     -- Bug 12211 - 10/12/2009 - AMC
    *************************************************************************/
   FUNCTION f_get_codevento(
      pcevento IN VARCHAR2,
      pcevento_out OUT VARCHAR2,
      pfinieve OUT DATE,
      pffineve OUT DATE)
      RETURN NUMBER IS
   BEGIN
      SELECT finieve, ffineve
        INTO pfinieve, pffineve
        FROM sin_codevento
       WHERE cevento = pcevento;

      pcevento_out := pcevento;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_eventos_sin.f_get_codevento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_codevento;

   /*************************************************************************
     Función f_set_codevento
     Función para insertar un evento
     param in pcevento  : codigo del evento
     param in PFINIEVE  : fecha inicio evento
     param in PFFINEVE  : fecha fin evento
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
    *************************************************************************/
   FUNCTION f_set_codevento(pcevento IN VARCHAR2, pfinieve IN DATE, pffineve IN DATE)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO sin_codevento
                     (cevento, finieve, ffineve)
              VALUES (pcevento, pfinieve, pffineve);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sin_codevento
               SET finieve = pfinieve,
                   ffineve = pffineve
             WHERE cevento = pcevento;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_eventos_sin.f_set_codevento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_codevento;

   /*************************************************************************
     Función f_del_evento
     Función para borrar un evento
     param in pcevento  : codigo del evento
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_del_evento(pcevento IN VARCHAR2)
      RETURN NUMBER IS
      vcount         NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcount
        FROM sin_desevento
       WHERE cevento = pcevento;

      IF vcount > 0 THEN
         DELETE FROM sin_desevento
               WHERE cevento = pcevento;
      END IF;

      DELETE      sin_codevento
            WHERE cevento = pcevento;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_eventos_sin.f_del_evento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_del_evento;

   /*************************************************************************
     Función f_set_desevento
     Función para insertar/actualizar la descripción de un evento
     param in pcevento  : codigo del evento
     param in pttiteve  : titulo del evento
     param in ptevento  : Descripción del evento
     param in pcidioma  : Codigo del idioma
     param out mensajes : mensajes de error
     return   0 - ok , 1 - ko

     -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_set_desevento(
      pcevento IN VARCHAR2,
      pttiteve IN VARCHAR2,
      ptevento IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO sin_desevento
                     (cevento, cidioma, ttiteve, tevento)
              VALUES (pcevento, pcidioma, pttiteve, ptevento);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sin_desevento
               SET ttiteve = pttiteve,
                   tevento = ptevento
             WHERE cevento = pcevento
               AND cidioma = pcidioma;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_eventos_sin.f_set_desevento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_desevento;
END pac_eventos_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_EVENTOS_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_EVENTOS_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_EVENTOS_SIN" TO "PROGRAMADORESCSI";
