--------------------------------------------------------
--  DDL for Package PAC_AGENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AGENDA" AS
/******************************************************************************
   NOMBRE:       PAC_AGENDA
   PROPÓSITO: Recupera les diferents configuracions d'accions disponibles

    REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/11/2010   XPL                Creación package
   2.0        25/02/2011   JMF              0017744: CRT - Mejoras en agenda
   3.0        25/07/2011   ICV              0018845: CRT901 - Modificacionas tareas usuario: boton responder, grupos, envio de mail al crear tarea,etc
   4.0        08/06/2012   APD              0022342: MDP_A001-Devoluciones
   5.0        31/08/2012   ASN              0023101: LCOL_S001-SIN - Apuntes de agenda automáticos - Se añade ntramit para apuntes automaticos de siniestros
   6.0        11/08/2017   JGONZALEZ        CONF-1005: Desarrollo de GAP 67 solicitud de apoyo tecnico
   7.0        17/04/2019   SGM              IAXIS 3482 SGM  17/04/2019  se agrega columna a la tabla agd_movobs para trazar mejor los apuntes   
******************************************************************************/
   FUNCTION f_get_literal_grupo(pcgrupo IN VARCHAR2, pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_nombre_grupo(pcempres IN NUMBER, ptgrupo IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_lstapuntes(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcidioma IN NUMBER,
      pfapunte IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pcusuari IN VARCHAR2,
      pcapuage IN VARCHAR2,
      pquery OUT CLOB,
      pcempres IN NUMBER,
      pcusuario IN VARCHAR2,
      pntramit IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_set_apunte(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      ptapunte IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcusuari IN VARCHAR2,
      pfapunte IN DATE,
      pfestapu IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pidapunte_out OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_movapunte(
      pidapunte IN NUMBER,
      pnmovapu IN NUMBER,
      pcestapu IN NUMBER,
      pfestapu IN DATE,
      pcusualt IN VARCHAR2 DEFAULT NULL,
      pfalta IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_set_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcperagd IN NUMBER,
      pcusuari_ori IN VARCHAR2 DEFAULT '',
      pcgrupo_ori IN VARCHAR2 DEFAULT '',
      ptgrupo_ori IN VARCHAR2 DEFAULT '',
      pcempres IN NUMBER DEFAULT NULL,
      pcidioma IN NUMBER DEFAULT NULL,
      ptevento IN VARCHAR2 DEFAULT 'NUEVA_TAREA',
      pntramit IN NUMBER DEFAULT NULL,   -- 23101:ASN:31/08/2012
      PTRESP IN VARCHAR2 default null) --CONF-347-01/12/2016-RCS
      RETURN NUMBER;

   FUNCTION f_set_chat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pttexto IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pctipres IN NUMBER,
      pcempres IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pcidioma IN NUMBER DEFAULT NULL,
      ptevento IN VARCHAR2 DEFAULT 'GENERAL')
      RETURN NUMBER;

/*************************************************************************
        Devuelve la lista de registros del chat de un apunte
        pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pttexto IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2)
        param out pquery  : Query con los conceptos a mostrar
        return                : 0/1 OK/KO

     *************************************************************************/
   FUNCTION f_get_lstchat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2,
      pcempres IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cuerpo(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      ptexto OUT VARCHAR2,
      pnapunte IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_asunto(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      psubject OUT VARCHAR2,
      psseguro IN NUMBER,
      pnapunte IN NUMBER,
      pnsinies IN VARCHAR2,
      pcmotmov IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_movagenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pnmovagd IN NUMBER,
      pcestagd IN NUMBER,
      pcusuari_ori IN VARCHAR2,
      pcgrupo_ori IN VARCHAR2,
      ptgrupo_ori IN VARCHAR2,
      pcusuari_dest IN VARCHAR2,
      pcgrupo_dest IN VARCHAR2,
      ptgrupo_dest IN VARCHAR2,
      pcusualt IN VARCHAR2 DEFAULT NULL,
      pfalta IN DATE DEFAULT NULL)
      RETURN NUMBER;

     --XPL bug 17770 25/03/2011 inici
   /*************************************************************************
        Devuelve la visibilidad de un apu/obs según la visión parametrizada para ese apunte.
        Dependerá del rol propietario del tipo de agenda, del usuario o del rol del usuario
        param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
        param in pidobs       : número obs/apu
        return                : 0/1 visión del apunte (1 visible para el usuario conectado, 0 No)
     *************************************************************************/
   FUNCTION f_obs_isvisible(pcempres IN NUMBER, pctipagd IN NUMBER, pidobs IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_entidad(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      ppfiltro IN VARCHAR2,
      pvalorfiltro IN VARCHAR2)
      RETURN VARCHAR2;

/*************************************************************************
        Devuelve la lista de los conceptos según el tipo de agenda
        del usuario, de su rol o del rol propietario de la agenda
        param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
        param out plstconceptos       : Cursor con los conceptos a mostrar
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_lstconceptos(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pctipagd IN NUMBER,
      pcmodo       IN       VARCHAR2,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Devuelve la lista de los tipos de agenda
        param out pquery       : query que devolveremos
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_lsttiposagenda(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Guardarem la obs/apu i crearem un apunt.
      Passarem en un objecte els valors SSEGURO, NRECIBO...
      En el cas que s'afegis una nova entitat de l'axis a l'agenda només hauriem
      de modificar la capa de negoci i afegir el nou camp ja que vindria en aquest objecte desde java.
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      psseguro IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL,
      pidobs_out OUT VARCHAR2
      return                : 0/1 OK/KO
   -- Bug 22342 - APD - 11/06/2012 - se añaden los parametros psseguro, pnrecibo,
   --  pcagente, pnsinies, pntramit
   *************************************************************************/
   FUNCTION f_set_obs(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      ppublico IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      pidobs_out OUT VARCHAR2,
      pdescripcion IN VARCHAR2 DEFAULT NULL,
      ptfilename IN VARCHAR2 DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
      Creamos un nuevo movimiento para el obs/apu
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pnmovobs IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_set_movobs(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pnmovobs IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      ptobs    IN VARCHAR2 DEFAULT NULL) --SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
      RETURN NUMBER;

   /*************************************************************************
          Devuelve la lista de los roles de la agenda, si nos pasan el tipo de agenda no devolveremos el rol
          propietario ya que no se podrá gestionar este rol, siempre será visible
           pcempres IN NUMBER,
           pcidioma IN NUMBER,
          pctipagd IN NUMBER,
          param out pquery       : query que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_lstroles(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pctipagd IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
           Devuelve la lista de la visión del obs/apu dependiendo el tipo que le pasamos
           pcempres IN NUMBER,
           pidobs IN NUMBER,
           pctipvision IN NUMBER,
           pcidioma IN NUMBER,
           param out pquery       : query que devolveremos
           return                : 0/1 OK/KO
        *************************************************************************/
   FUNCTION f_get_lstvision(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      pctipvision IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

      /*************************************************************************
      Guardarem la visió d'un apunt
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      pcvisible IN NUMBER
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_set_vision(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      pcvisible IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
            Borramos un apunte/observacion
            pidobs IN NUMBER,
            return                : 0/1 OK/KO
         *************************************************************************/
   FUNCTION f_del_observacion(pcempres IN NUMBER, pidobs IN NUMBER)
      RETURN NUMBER;

     /*************************************************************************
      Devuelve la lista grupos
       pcempres IN NUMBER,
       pcidioma IN NUMBER,
       param out pquery       : query que devolveremos
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lstgrupos(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER;

          /*Funció que retorna el valor a mostrar per pantalla.
   Si es un apunt de pòlissa, retornarà npol + ncertif, si és de rebut nrecibo i si és sinistre el nsinies.
   XPL#14102011#
   */
   FUNCTION f_get_valorclagd(pcclagd IN VARCHAR2, ptclagd IN VARCHAR2, pquery OUT VARCHAR2)
      RETURN NUMBER;

     /*Funció que crear tasca de la solicitud de projecte
   XPL#24102011#
   */
   FUNCTION f_tarea_sol_proyecto(psseguro IN NUMBER, pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;
END pac_agenda;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGENDA" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_AGENDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGENDA" TO "CONF_DWH";
