--------------------------------------------------------
--  DDL for Package PAC_TRAMITADORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TRAMITADORES" AS
    /******************************************************************************
      NOMBRE:       PAC_TRAMITADORES
      PROPÃ“SITO:  Funciones para recuperar valores

      REVISIONES:
      Ver        Fecha        Autor   Descripcion
     ---------  ----------  ------   ------------------------------------
      1.0        07/05/2012   AMC     1. Creacion del package.
      2.0        06/08/2012   ASN     0023101: LCOL_S001-SIN - Apuntes de agenda automáticos

   ******************************************************************************/

   /*************************************************************************
        FUNCTION f_get_ctramitad
        Recupera els tramidors amb les seves descripcions
        param in pctramitad  : codi tramitador
        param in  out pttramitad  : Nombre de tramitador
        param out mensajes : missatges d'error
        return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tramitador(pctramitad IN VARCHAR2, pttramitad IN OUT VARCHAR2)
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION f_cambio_tramitador
        Inserta el movimiento de cambio de tramitador
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_cambio_tramitador(
      psiniestros IN VARCHAR2,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2)
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION f_mensaje_asignacion
        Inserta mensaje en la agenda cuando se asigna un tramite/tramitacion
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_mensaje_asignacion(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION f_apunte_repetido
        Comprueba si ya hay un apunte igual en la agenda de un tramitador
        param in pcusuari  : codigo usuario
        param in pnsinies  : Numero siniestro
        param in pcconapu  : concepto apunte
        param in pctipapu  : tipo de apunte
        param in pttitulo  : titulo apunte
        param out apunte_repetido : 1=si 0=no
   *************************************************************************/
   FUNCTION f_apunte_repetido(
      pcusuari IN VARCHAR2,
      pnsinies IN VARCHAR2,
      pcconapu IN NUMBER,
      pctipapu IN NUMBER,
      pttitulo IN VARCHAR2,
      papunte_repetido OUT NUMBER)
      RETURN NUMBER;

   /****************************************************************************
   Replica un apunte cuando el destinatario es tramitador global en las agendas
   de los tramitadores de todas las tramitaciones abiertas
      23101:ASN:31/07/2012
   ****************************************************************************/
   FUNCTION f_replica_apunte(pidapunte IN NUMBER, pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

   /****************************************************************************
    Traspasa los apuntes abiertos a la agenda del nuevo tramitador
       23101:ASN:31/07/2012
   ****************************************************************************/
   FUNCTION f_traspasa_agenda(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnmovtra IN NUMBER,
      pcuniori IN VARCHAR2,
      pctramiori IN VARCHAR2,
      pcunidest IN VARCHAR2,
      pctramidest IN VARCHAR2)
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION f_reasignacion
        Comprueba si ha habido cambio de tramitador y realiza las acciones pertinentes
        param in pnsinies    : numero siniestro
        param in pntramit    : numero tramitacion
        param in pnmovimi    : numero de movimiento (tramite o tramitacion)
        param in pcunitra    : codigo de la unidad de tramitacion
        param in pctramitad  : codigo del tramitador
        return               : 0 - OK , SQLERRM - KO
   *************************************************************************/
   FUNCTION f_reasignacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnmovimi IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2)
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION f_mensaje_siniestro
        Inserta mensaje en la agenda del tramitador
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pctramitad  : codi tramitador
        param in pcunitra : codi de la unidad de tramitacion
        param in pctramitad : codi del tramitador
        param in pcconapu  : tipo apunte
        param in pslittit  : literal titulo
        param in pslitbod  : literal body
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_mensaje_siniestro(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pcconapu IN NUMBER,
      pslittit IN NUMBER,
      pslitbod IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION f_msg_tramitador_global
        Inserta mensaje en la agenda del tramitador global del siniestro
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pcconapu  : tipo apunte
        param in pslittit  : literal titulo
        param in pslitbod  : literal body
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_msg_tramitador_global(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcconapu IN NUMBER,
      pslittit IN NUMBER,
      pslitbod IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION f_msg_responsable
        Inserta mensaje en la agenda del responsable de siniestros
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        param in pcconapu  : tipo apunte
        param in pslittit  : literal titulo
        param in pslitbod  : literal body
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_msg_responsable(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcconapu IN NUMBER,
      pslittit IN NUMBER,
      pslitbod IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
        FUNCTION f_anula_msg_asignacion
        Anula el mensaje de asignacion si procede
        param in pctramitad: tramitador
        param in pnsinies  : numero siniestro
        param in pntramte  : numero tramite
        param in pntramit  : numero tramitacion
        return             : 0 - Ok , SQLERRM - Ko
   *************************************************************************/
   FUNCTION f_anula_msg_asignacion(
      pctramitad IN VARCHAR2,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER)
      RETURN NUMBER;
END pac_tramitadores;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRAMITADORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRAMITADORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRAMITADORES" TO "PROGRAMADORESCSI";
