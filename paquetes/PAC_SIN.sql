--------------------------------------------------------
--  DDL for Package PAC_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN" AUTHID CURRENT_USER IS
/****************************************************************************
   NOMBRE:       PAC_SIN
   PROPÓSITO:  Funciones para los módulos del área SIN

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        ???         ???               1. Creación del package.
   2.0        19/03/2009  JRB               2. Se añaden las fechas para identificar los pagos
****************************************************************************/
   FUNCTION f_reajustar_ctaseguro(p_nsinies IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER;

   --Funcion que indica si se debe reajustar o no un seguro cuyo siniestro ha sido reabrierto
   FUNCTION f_datosnsinies(
      pnsinies IN NUMBER,
      pfsinies OUT DATE,
      ptsinies OUT VARCHAR2,
      pcculpab OUT NUMBER)
      RETURN NUMBER;

  --Retorna les dades del sinitre
--------------------------------------------------------------------
   FUNCTION f_ivapago(psidepag IN NUMBER, pptipiva OUT NUMBER)
      RETURN NUMBER;

  --Retorna el porcentatge d'IVA a aplicar
--------------------------------------------------------------------
   FUNCTION f_iimpiva(pisinret IN NUMBER, pptipiva IN NUMBER, pimpiva OUT NUMBER)
      RETURN NUMBER;

  --Retorna el IIMPIVA per uns ISINRET i PTIPIVA donats
--------------------------------------------------------------------
   FUNCTION f_valoracio(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      valoracio OUT NUMBER)
      RETURN NUMBER;

  --Retorna la valoració d'una garantia a una certa data
--------------------------------------------------------------------
   FUNCTION f_pagos(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      pagos OUT NUMBER)
      RETURN NUMBER;

  --Retorna els pagaments fets fins a una certa data
--------------------------------------------------------------------
   FUNCTION f_destramitacionsini(
      psseguro IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      pttramit OUT VARCHAR2,
      plongitud IN NUMBER DEFAULT 500)
      RETURN NUMBER;

  --Retorna la desc d'una tramitacio d'un sinistre
--------------------------------------------------------------------
   FUNCTION f_desvehicle_aseg(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pmatricula OUT VARCHAR2,
      pcolor OUT VARCHAR2,
      pmarca OUT VARCHAR2,
      pmodelo OUT VARCHAR2,
      pversion OUT VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER;

--------------------------------------------------------------------
   FUNCTION f_iconret(pisinret IN NUMBER, pretenc IN NUMBER, piconret OUT NUMBER)
      RETURN NUMBER;

  --Retorna el ICONRET per uns ISINRET i un PRETENC
--------------------------------------------------------------------
   FUNCTION f_retencpago(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pdata IN DATE,
      pretenc OUT NUMBER)
      RETURN NUMBER;

  --Retorna el porcentatge de retencio a aplicar
--------------------------------------------------------------------
   FUNCTION f_ctipcoa(psseguro IN NUMBER, pctipcoa OUT NUMBER)
      RETURN NUMBER;

  --Retorna ctipcoa del seguro
--------------------------------------------------------------------
   FUNCTION f_descausasini(pccausin IN NUMBER, pcidioma IN NUMBER, ptcausin OUT VARCHAR2)
      RETURN NUMBER;

  -- Retorna la descripcio de la causa de sinistre
--------------------------------------------------------------------
   FUNCTION f_crefsin(
      pnsinies IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pcrefsin OUT VARCHAR2)
      RETURN NUMBER;

  -- Retorna la referencia del sinistre del destinatari
--------------------------------------------------------------------
   FUNCTION f_crefint(pnsinies IN NUMBER, ptramitador IN VARCHAR2, pcrefint OUT VARCHAR2)
      RETURN NUMBER;

  -- Retorna la referencia interna del sinistre
--------------------------------------------------------------------
   FUNCTION f_desdiario(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pnlintra IN NUMBER,
      pcidioma IN NUMBER,
      pdesc OUT VARCHAR2)
      RETURN NUMBER;

  -- Retorna la descripció de una linea de diari
--------------------------------------------------------------------
   FUNCTION f_desglosegarant(psidepag IN NUMBER)
      RETURN NUMBER;

  -- Inserta el detall d'un pagament a un altre pagament
--------------------------------------------------------------------
   FUNCTION f_mantdiario(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      ptlintra IN VARCHAR2)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 99 esto quiere decir
  -- que el usuario habrá introducido manualmente
  -- la descripción en el diario.
--------------------------------------------------------------------
   FUNCTION f_mantdiario_asig(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      psasigna IN NUMBER,
      pnlocali IN NUMBER,
      ptlintra IN VARCHAR2)
      RETURN NUMBER;

  -- Función que introduce los cambios de asignacion
  -- de profesionales a diariotramitacion. El código
  -- asignado a esta linea de tramitación es el 3
  -- en el campo tlintra grabaremos como se ha asignado la
  -- localización ('MAN' o 'AUT').
--------------------------------------------------------------------
   FUNCTION f_mantdiario_desti(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 4 esto quiere decir
  -- que se ha modificado la tabla de destinatrami.
--------------------------------------------------------------------
   FUNCTION f_mantdiario_locali(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcidioma IN NUMBER,
      pnlocali IN NUMBER)
      RETURN NUMBER;

  -- Función que inserta en la tabla de diariotramitación
  -- se utilizará cuando se produzcan cambios en la tabla
  -- de localizatrami y el código asignado a esta linea de
  -- tramitación es el 1.
--------------------------------------------------------------------
   FUNCTION f_mantdiario_pagogaran(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      psidepag IN NUMBER)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 7 esto quiere decir
  -- que se ha modificado la tabla de pagogarantrami.
--------------------------------------------------------------------
   FUNCTION f_mantdiario_pagosini(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      pcestado IN NUMBER,
      psperson IN NUMBER)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 6 esto quiere decir
  -- que se ha modificado la tabla de pagosinitrami.
--------------------------------------------------------------------
   FUNCTION f_mantdiario_tram(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcestado IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 2 esto quiere decir
  -- que se ha modificado la tabla de tramitacionsini.
--------------------------------------------------------------------
   FUNCTION f_mantdiario_valora(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pnvalora IN NUMBER)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 5 esto quiere decir
  -- que se ha modificado la tabla de valorasinitrami.
--------------------------------------------------------------------
   FUNCTION f_mantdiario_diarioprof(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pnlinpro IN NUMBER,
      pcestado IN NUMBER)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 8 esto quiere decir
  -- que se ha modificado la tabla de diarioproftrami
--------------------------------------------------------------------
   FUNCTION f_mantdiario_dano(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

  -- Función que se utilizará cuando el código de
  -- linea de tramitación sea 9 esto quiere decir
  -- que se ha modificado la tabla de danostrami
--------------------------------------------------------------------
   FUNCTION f_newnlintra(pnsinies IN NUMBER, pntramit IN NUMBER, pnlintra OUT NUMBER)
      RETURN NUMBER;

  -- Función que te genera el próximo código de
  -- linea de tramitación.
--------------------------------------------------------------------
   FUNCTION f_mantdiarioprof(
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      ptiplin IN NUMBER,
      pcestado IN NUMBER,
      pcforenv IN NUMBER,
      ptdocume IN VARCHAR)
      RETURN NUMBER;

--------------------------------------------------------------------
   FUNCTION f_provisio(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER)
      RETURN NUMBER;

  --Retorna la PROVISIÓ d'una garantia a una certa data
--------------------------------------------------------------------
   FUNCTION f_iconiva(psidepag IN NUMBER, piconiva OUT NUMBER)
      RETURN NUMBER;

  --Retorna l'import al qual s'ha d'aplicar IVA d'un pagament
--------------------------------------------------------------------
   FUNCTION f_iretenc(ppretenc IN NUMBER, piconret IN NUMBER, piretenc OUT NUMBER)
      RETURN NUMBER;

  --Retorna l'import de la retenció
--------------------------------------------------------------------
   FUNCTION f_ins_destinatrami(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pcactpro IN NUMBER,
      pcrefsin IN NUMBER)
      RETURN NUMBER;

  -- Funció per inserir un destinatari
--------------------------------------------------------------------
   FUNCTION f_peticiodoc(pnsinies IN NUMBER, pntramit IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

  -- Inserta a DIARIOPROFTRAMI les peticions de DOC
--------------------------------------------------------------------
   FUNCTION f_tramitautomac(pnsinies IN NUMBER)
      RETURN NUMBER;

  -- Genera automàticament les tramitacions necesaries segons la info entrada al 008
--------------------------------------------------------------------
   FUNCTION f_insert_tramita(pnsinies IN NUMBER, pctramit IN NUMBER)
      RETURN NUMBER;

  -- Realitza inserts a DIARIOPROFTRAMI
----------------------------------------------------------------------------------
   FUNCTION f_valoracio_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      valoracio OUT NUMBER)
      RETURN NUMBER;

  -- Bug 8744 - 03/03/2009 - JRB - Se añaden las fechas de inicio y fin para el cálculo de los pagos
  -- Calcula la valoracio a nivell de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_pagos_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      pagos OUT NUMBER,
      plevelpag IN NUMBER DEFAULT 0,
      pfperini IN DATE DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

-- Bug 8744 - 03/03/2009 - JRB - Se crea la funcion de pago automático
/*************************************************************************
   FUNCTION f_pago_aut
   Crea un pago automático
   param in pdata   : fecha final de pago
   return             : código de error
*************************************************************************/
   FUNCTION f_pago_aut(p_data IN DATE)
      RETURN NUMBER;

  -- Calcula els pagaments a nivell de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_provisio_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER,
      plevelpag IN NUMBER DEFAULT 0)
      RETURN NUMBER;

  -- Calcula la provisio a nivell de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_insctactescia(psidepag IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

  --F_INSCTACTESCIA: Inserta en ctactescia para un siniestro.
---------------------------------------------------------------------------------
   FUNCTION f_refsiniestro(pnsinies IN NUMBER, pcrefint IN OUT VARCHAR2)
      RETURN NUMBER;

  --F_REFSINIESTRO: Obtener el campo crefint a partir del
  --identificador del siniestro.
-------------------------------------------------------------------------------------
   FUNCTION f_inicializar_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pnsubest IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

------------------------------------------------------------------------------------------
   FUNCTION f_inicializar_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pnsubest IN NUMBER,
      pnsinies OUT NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_permite_alta_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER)
      RETURN NUMBER;

--------------------------------------------------------------------------------------------
   FUNCTION f_accion_siniestro(
      pnsinies IN NUMBER,
      paccion IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_constar_fallecimiento(
      vsseguro IN NUMBER,
      vsproduc IN NUMBER,
      pnsinies IN NUMBER,
      vfsinies IN DATE)
      RETURN NUMBER;

-----------------------------------------------------------------------------------
   FUNCTION f_insctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insctaseguro_shw(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER;

-------------------------------------------------------------------------------------
   FUNCTION f_estatsini(pnsinies IN NUMBER)
      RETURN NUMBER;

-------------------------------------------------------------------------------------
   FUNCTION f_estatpago(psidepag IN NUMBER)
      RETURN NUMBER;

-------------------------------------------------------------------------------------
   FUNCTION f_finalizar_sini(
      pnsinies IN NUMBER,
      ptipo IN NUMBER,
      pccauest IN NUMBER,
      pfecha IN DATE,
      pliteral IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

--Controla la anulacion o el rechazo de un siniestro
-------------------------------------------------------------------------------------
   FUNCTION f_provisio_total(
      pnsinies IN NUMBER,
      pdata IN DATE,
      provisio OUT NUMBER,
      plevelpag IN NUMBER DEFAULT 0)
      RETURN NUMBER;

  --Calcula la provision total de un siniestro
-------------------------------------------------------------------------------------
   FUNCTION f_anu_sini_mov(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

--Controla la anulacion de un siniestro por el movimiento de la poliza.
   FUNCTION ff_sperson_sinies(pnsinies IN NUMBER)
      RETURN NUMBER;

--Función que devuelve el sperson de la persona siniestrada. Si el producto es a 2_Cabezas, el sperson se busca de la tabla ASEGURADOS,
-- sino de la tabla RIESGOS
   FUNCTION f_reabrir_sini(pnsinies IN NUMBER)
      RETURN NUMBER;

-- Función que reabre un siniestro
---------------------------------------------------------------------------------
   FUNCTION f_rcm_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      resrcm OUT NUMBER)
      RETURN NUMBER;

  -- Calcula els rcm a nivell de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_iretenc_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      retenc OUT NUMBER)
      RETURN NUMBER;

  -- Calcula la Retenció a nivell de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_reduccion_sini(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pdata IN DATE,
      resred OUT NUMBER)
      RETURN NUMBER;

  -- Calcula la Reducció a nivell de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_desmotsini(
      pcramo IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcidioma IN NUMBER,
      ptmotsin OUT VARCHAR2)
      RETURN NUMBER;

  -- Retorna la descripcio del motiu de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_constar_culpabilidad(pnsinies IN NUMBER, pcculpab IN NUMBER)
      RETURN NUMBER;
  -- Actualitza la culpabilitat d'un sinistre
---------------------------------------------------------------------------------
END pac_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN" TO "PROGRAMADORESCSI";
