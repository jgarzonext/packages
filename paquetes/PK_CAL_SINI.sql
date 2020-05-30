--------------------------------------------------------
--  DDL for Package PK_CAL_SINI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_CAL_SINI" AUTHID CURRENT_USER IS
/****************************************************************************
   NOMBRE:       PAC_SIN
   PROPÓSITO:  Funciones para el cálculo de los siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        ???         ???               1. Creación del package.
   2.0        19/03/2009  JRB               2. Se añaden las fechas para identificar los pagos
   3.0        07/10/2013  HRE               3. Bug 0028462: HRE - Cambio dimension campo sseguro
****************************************************************************/
   TYPE t_valores IS RECORD(
      ttipo          NUMBER(1),
      ssegu          NUMBER,   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO
      perso          NUMBER(6),
      desti          NUMBER(2),
      ffecefe        NUMBER(8),
      cactivi        NUMBER(4),   -- Actividad
      cgarant        NUMBER(4),   -- Garantía
      ivalsin        NUMBER,   -- Valoración siniestro
      isinret        NUMBER,   -- Bruto pago
      iresrcm        NUMBER,   -- Rendimientos
      iresred        NUMBER,   -- Reducción
      iconret        NUMBER,   -- Base de Retención
      pretenc        NUMBER,   -- % de Retención
      iretenc        NUMBER,   -- Importe de Retención
      iimpsin        NUMBER,   -- Importe neto
      icapris        NUMBER,   -- K EN RIESGO
      ipenali        NUMBER,   -- Importe penalizacion
      iprimas        NUMBER,
      fperini        NUMBER(8),   -- Fecha Inicio Pago
      fperfin        NUMBER(8)   -- Fecha Fin Pago
   );

   TYPE t_val IS TABLE OF t_valores
      INDEX BY BINARY_INTEGER;

   valores        t_val;
-- Variables Globales
   gnvalor        NUMBER := 0;   -- Contador de recibos generados

   -- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetros pfperini y pfperfin
   FUNCTION gen_pag_sini(
      pfsinies IN DATE,   -- Fecha del siniestro
      psseguro IN NUMBER,   -- clave del seguro
      pnsinies IN NUMBER,   -- Nro de siniestro
      psproduc IN NUMBER,   -- Clave del Producto
      pcactivi IN NUMBER DEFAULT 0,   -- Actividad
      pccausin IN NUMBER,   -- Causa del Siniestro
      pcmotsin IN NUMBER,   -- Subcausa
      pfnotifi IN DATE,   -- Fecha de Notificacion
      pnriesgo IN NUMBER DEFAULT NULL,
      p_fperini IN DATE DEFAULT NULL,
      p_fperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetros pfperini y pfperfin
   FUNCTION calc_pagos_sini(
      pnsinies IN NUMBER,   -- Nro. de Siniestro
      psproduc IN NUMBER,   -- SPRODUC
      pcactivi IN NUMBER,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      psseguro IN NUMBER,   -- SSEGURO
      pfsinies IN DATE,   -- Fecha
      pccausin IN NUMBER,   -- Causa del Siniestro
      pcmotsin IN NUMBER,   -- Subcausa
      pfnotifi IN DATE,   -- Fecha de Notificacion
      psperdes IN NUMBER,   -- sperson del destinatario
      pctipdes IN NUMBER,   -- tipo de destinatario
      pnriesgo IN NUMBER DEFAULT NULL,
      p_fperini IN DATE DEFAULT NULL,
      p_fperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetros pfperini y pfperfin
   FUNCTION valo_pagos_sini(
      pfsinies IN DATE,   -- Fecha del siniestro
      psseguro IN NUMBER,   -- clave del seguro
      pnsinies IN NUMBER,   -- Nro de siniestro
      psproduc IN NUMBER,   -- Clave del Producto
      pcactivi IN NUMBER DEFAULT 0,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      pccausin IN NUMBER,   -- Causa del Siniestro
      pcmotsin IN NUMBER,   -- Subcausa
      pfnotifi IN DATE,   -- Fecha de Notificacion
      pivalora OUT NUMBER,   -- Valoracion
      pipenali OUT NUMBER,   -- Penalizacion
      picapris OUT NUMBER,   -- Capital de riesgo
      pnriesgo IN NUMBER DEFAULT NULL,
      pfecval IN DATE DEFAULT f_sysdate,
      p_fperini IN DATE DEFAULT NULL,
      p_fperfin IN DATE DEFAULT NULL)   --Data per calcul de la valoracio
      RETURN NUMBER;

/*
   FUNCTION ins_destina_autom(
                         pfsinies   IN DATE,   -- Fecha del siniestro
                         psseguro IN NUMBER,   -- clave del seguro
                         pnsinies IN NUMBER,      -- Nro de siniestro
                         psproduc IN NUMBER,      -- Clave del Producto
                         pcactivi IN NUMBER DEFAULT 0, -- Actividad
                         pcgarant IN NUMBER,      -- Garantía
                         pccausin IN NUMBER,
                         pcmotsin IN NUMBER,   -- Subcausa
                         pivalora OUT NUMBER)  -- Valoración
    RETURN NUMBER;
*/

   -- Bug 8744 - 03/03/2009 - JRB - Se añaden los parámetros pfperini y pfperfin
   FUNCTION insertar_mensajes(
      ptipo IN NUMBER,   -- Tipo 0-Valoración 1-Pago
      pseguro IN NUMBER,   -- Clave del Seguro
      psperson IN NUMBER,   -- Clave Persona
      pctipdes IN NUMBER,   -- Tipo destinatario
      pffecha IN NUMBER,   -- Fecha siniestro
      pcactivi IN NUMBER,   -- Actividad
      pcgarant IN NUMBER,   -- Garantía
      pvalsin IN NUMBER,   -- Valoración del Siniestro
      pisinret IN NUMBER,   -- Bruto
      piresrcm IN NUMBER,   -- Rendimientos
      piresred IN NUMBER,   -- Rendimientos Reducidos
      piconret IN NUMBER,   -- Importe Base
      ppretenc IN NUMBER,   -- % de Retención
      piretenc IN NUMBER,   -- Importe de Retención
      piimpsin IN NUMBER,   -- Importe Neto
      picapris IN NUMBER,
      pipenali IN NUMBER,
      piprimas IN NUMBER,
      p_fperini IN NUMBER,   -- Fecha inicio pago
      p_fperfin IN NUMBER)
      RETURN NUMBER;

   FUNCTION insertar_pagos(pnsinies IN NUMBER)   -- Nro. de siniestro
      RETURN NUMBER;

   FUNCTION graba_param(wnsesion IN NUMBER, wparam IN VARCHAR2, wvalor IN NUMBER)
      RETURN NUMBER;

   FUNCTION borra_param(wnsesion IN NUMBER)
      RETURN NUMBER;

   FUNCTION ver_mensajes(nerr IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE borra_mensajes;

   FUNCTION retorna_valores
      RETURN t_val;

   FUNCTION f_simu_calc_sini(
      pfsinies IN DATE,
      pfnotifi IN DATE,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      picapital IN NUMBER DEFAULT NULL,
      pnriesgo IN NUMBER DEFAULT NULL,
      pfecval IN DATE DEFAULT NULL,
      pctipdes IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_imaximo_rescatep(
      psseguro IN NUMBER,
      pfsinies IN DATE,
      pccausin IN NUMBER,
      pimporte OUT NUMBER)
      RETURN NUMBER;
END pk_cal_sini;

/

  GRANT EXECUTE ON "AXIS"."PK_CAL_SINI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CAL_SINI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CAL_SINI" TO "PROGRAMADORESCSI";
