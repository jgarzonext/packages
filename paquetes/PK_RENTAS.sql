--------------------------------------------------------
--  DDL for Package PK_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_RENTAS" AUTHID CURRENT_USER IS
   /****************************************************************************
      NOMBRE:     PK_RENTAS
      PROPÓSITO:  Cuerpo del paquete de las funciones utilizadas RENTAS

      REVISIONES:
      Ver        Fecha           Autor             Descripción
      ---------  ----------     -------    ----------------------------------
      1.0                                   Creación del package.
      2.0        06/2009         NMM        0010240: CRE - Ajustes en pagos de renta extraordinarias .
      3.0        16/06/2009      JGM       1. Actualización Generacion Rentas
      4.0        11/02/2010      AMC       2. 0011392: CRE - Añadir a la consulta de pólizas las rentas.
      5.0        20/04/2010      ICV       3. 0012914: CEM - Reimprimir listados de pagos de rentas
     10.0        03/06/2010      JGR       10. 0014658: CRE998- Parametrizar día de pago en Rentas Irregulares
     11.0       10/08/2010       JRH       11. BUG 15669 : Campos nuevos
     12.0       05/09/2010       JRH       12. BUG 0016217: Mostrar cuadro de capitales para la pólizas de rentas
     13.0       15/12/2010       APD       13. BUG 0017005: CEM800 - Ajustes modelos fiscales
     14.0       15/03/2010       JTS       14. BUG 0013477: ENSA101 - Nueva pantalla de Gestión Pagos Rentas
     15.0       29/03/2011       JMF       15. BUG 0013477 ENSA101 - Nueva pantalla de Gestión Pagos Rentas
     16.0        03/2013         NMM       16. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
   ****************************************************************************/
   TYPE t_valores IS RECORD(
      ssegu          NUMBER(6),
      perso          NUMBER(10),
      asegu          NUMBER(1),
      ffecefe        NUMBER(8),
      isinren        NUMBER,
      ibasren        NUMBER,
      pretren        NUMBER,
      iretren        NUMBER,
      iconren        NUMBER
   );

   TYPE t_val IS TABLE OF t_valores
      INDEX BY BINARY_INTEGER;

   valores        t_val;
   gestmort1      NUMBER;
   gestmort2      NUMBER;
   gcmunrec       NUMBER;
   gcestmre       NUMBER;
   gnrecren       NUMBER;
   gcestmre_pol   NUMBER;
   gcblopag       NUMBER;
   gnvalor        NUMBER;
   gnpoliz        NUMBER;
   gstmppagren    NUMBER;

   -- ****************************************************************
  -- calc_rentas
-- Genera el recibo de renta para una fecha 0-Modo Real 1-Modo Previo

   --         Funció que genera les prestacions d'una pòlissa
--       param in pproceso : Proceso
--       param in psseguro : Clave seguro
--       param in psperson  : Persona
--       param in psperson2  : Persona2
--       param in pnroaseg : Número asegurado
--       param in pibruren : Importe renta
--       param in pfppren : Fecha próxima renta
--       param in pfefecto : Fecha efecto
--       param in pf1pren :Fecha Primer pago
--       param in pctabanc: Cuenta
--       param in ptiporen :  Tipo renta
--       param in prealpre :  -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
--         return            : 1 -> Tot correcte
--                             0 -> S'ha produit un error
-- ****************************************************************
-- ****************************************************************
   FUNCTION calc_rentas(
      pproceso IN NUMBER,   -- Nro. Proceso o Nro. Recibo
      pseguros IN NUMBER,   -- SSEGURO
      psperson IN NUMBER,   -- SPERSON 1er. Asegurado
      psperson2 IN NUMBER,   -- SPERSON 2on. Asegurado
      pnroaseg IN NUMBER,   -- Nro. de Asegurados 1 o 2
      psproduc IN NUMBER,   -- SPRODUC
      pibruren IN NUMBER,   -- BRUTO RENTA
      prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
      pf1pren IN DATE,   -- Fecha 1er. pago de Renta
      pfppren IN DATE,   -- Fecha Proximo pago de renta
      pfefecto IN DATE,   -- Fecha
      pctabanc IN VARCHAR2,   -- Cuenta Bancaria
      ptiporen IN VARCHAR2,   -- Tipo de renta
      pctipban IN NUMBER)
      RETURN NUMBER;

-- ****************************************************************
--gen_rec_pol
-- Genera pagos de una póliza

   --         Param in pfecha : fecha
--         Param in pseguro : seguro
-- return 0 o <>0 si hay error
-- ****************************************************************
   FUNCTION gen_rec_pol(pfecha IN DATE, pseguro IN NUMBER)
      RETURN NUMBER;

-- ****************************************************************
-- gen_rec_renta
-- Busca todas las polizas que hay que generar pagos

   --         Param in pfecha : fecha
--         Param in pcidioma : idioma
--         Param in pctipo : tipo -- 0-Real,1-Previo Ins.Tabla, 3-Previo Mens.
--         Param in psproduc : producto
--         Param in pusuario : cCódigo Usuario
--         Param in pseqtip1 : secencia -- Si pctipo=1 numero secuencia.
--         Param in pcempres : empresa
--         Param in psproces : proceso
--         Param out pnerror : Código error
-- return 0 o <>0 si hay error
-- ****************************************************************
   PROCEDURE gen_rec_rentas(
      pfecha IN DATE,   -- Fecha Pago
      pcidioma IN NUMBER,   -- Idioma
      pctipo IN NUMBER,   -- 0-Real,1-Previo Ins.Tabla, 3-Previo Mens.
      psproduc IN NUMBER,   -- Sequence del producto
      pusuario IN VARCHAR2,   -- Nombre Usuario
      pseqtip1 IN NUMBER,   -- Si pctipo=1 numero secuencia.
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pnerror OUT NUMBER);   --Bug.: 10432 - 20/04/2010 - ICV - Reimprimir listados de pagos de rentas

-- ****************************************************************
 --gen_calc_pol
-- Generar pagos de una póliza
   -- Mantis 10240.#6.i.06/2009.NMM.Afegim el paràmetre p_nmesextra.
   --       param in pproceso : Proceso
--       param in psseguro : Clave seguro
--       param in psperson  : Persona
--       param in psperson2  : Persona2
--       param in pnroaseg : Número asegurado
--       param in pibruren : Importe renta
--       param in pfppren : Fecha próxima renta
--       param in pfefecto : Fecha efecto
--       param in pf1pren :Fecha Primer pago
--       param in pctabanc: Cuenta
--       param in ptiporen :  Tipo renta
--       param in prealpre :  -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
--         return            : 1 -> Tot correcte
--                             0 -> S'ha produit un error
-- ****************************************************************
   FUNCTION gen_calc_pol(
      psseguro IN NUMBER,   -- Clave seguro
      pfecha IN DATE,   -- Fecha pago
      pfppren IN DATE,   -- Fecha proximo pago
      pibruren IN NUMBER,   -- Importe bruto renta
      pcforpag IN NUMBER,   -- Forma pago renta
      pf1paren IN DATE,   -- Fecha inicio renta
      pfefecto IN DATE,   -- Fecha
      pcbancar IN VARCHAR2,   -- CCC
      psproduc IN NUMBER,   -- Clave producto
      prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
      pproceso IN NUMBER,   -- Nro. proceso
      ptiporen IN OUT VARCHAR2,   -- Tipo de renta
      p_nmesextra IN VARCHAR2,   -- Mesos amb paga extra.
      pctipban IN NUMBER)
      RETURN NUMBER;

   FUNCTION cambia_estado_recibo(
      psrecren IN NUMBER,   -- Clave del Recibo
      pfmovini IN DATE,   -- Fecha del nuevo movimiento
      pcestrec IN NUMBER)   -- Nuevo Estado
      RETURN NUMBER;

-- ****************************************************************
--insertar_mensajes
-- Graba recibos y movimientos
--      param in pseguro : -- Clave del Seguro
--      param in psperson :   -- Clave Persona
--      param in pnorden:   -- Nro Orden
--      param in ppretren :  -- % de Retención
--      param in pfppren : -- Fecha efecto
--      param in piretren :   -- Importe de Retención
--      param in pibasren :  -- Importe Base
--      param in piconren :   -- Importe con Retención (NETO)
--      param in pisinren :   -- Importe sin Retención (BRUTO)
--      param in pcbancar :   -- CCC donde se ingresa el pago
--      param in pctipo :  -- 1-Ins.Temporal 3-Mensajes
--      psproces IN NUMBER : Proceso
--      param in pctipban : Tipban
--      param in pnsinies : Siniestro
--      param in pntramit : Trámite
--      param in pctipdes : Tipo de destinatario
-- retorna 0 o <> 0 si hay error
-- ****************************************************************
   FUNCTION insertar_mensajes(
      pseguro IN NUMBER,   -- Clave del Seguro
      psperson IN NUMBER,   -- Clave Persona
      pnorden IN NUMBER,   -- Nro Orden
      ppretren IN NUMBER,   -- % de Retención
      pfppren IN NUMBER,   -- Fecha efecto
      piretren IN NUMBER,   -- Importe de Retención
      pibasren IN NUMBER,   -- Importe Base
      piconren IN NUMBER,   -- Importe con Retención (NETO)
      pisinren IN NUMBER,   -- Importe sin Retención (BRUTO)
      pcbancar IN VARCHAR2,   -- CCC donde se ingresa el pago
      pctipo IN NUMBER,   -- 1-Ins.Temporal 3-Mensajes
      psproces IN NUMBER,
      pctipban IN NUMBER,
      pnsinies IN VARCHAR2 DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL,
      pctipdes IN NUMBER DEFAULT NULL,
      pnpresta IN NUMBER DEFAULT 1)   -- Proceso
      RETURN NUMBER;

-- ****************************************************************
--insertar_pagos
-- Graba recibos y movimientos
--      param in pseguro : -- Clave del Seguro
--      param in psperson :   -- Clave Persona
--      param in pnorden:   -- Nro Orden
--      param in ppretren :  -- % de Retención
--      param in pfppren : -- Fecha efecto
--      param in piretren :   -- Importe de Retención
--      param in pibasren :  -- Importe Base
--      param in piconren :   -- Importe con Retención (NETO)
--      param in pisinren :   -- Importe sin Retención (BRUTO)
--      param in pcbancar :   -- CCC donde se ingresa el pago
--      param in pctipo :  -- 1-Ins.Temporal 3-Mensajes
--      param IN psproces : Proceso
--      param in pctipban : Tipban
--      param in pnsinies : Siniestro
--      param in pntramit : Trámite
--      param in pctipdes : Tipo de destinatario
--      param out idpago: código del pago
-- retorna 0 o <> 0 si hay error
-- ****************************************************************
   FUNCTION insertar_pagos(
      pseguro IN NUMBER,   -- Clave del Seguro
      psperson IN NUMBER,   -- Clave Persona
      pfppren IN DATE,   -- Fecha Efecto
      pisinren IN NUMBER,   -- Importe sin Retención (BRUTO)
      ppretren IN NUMBER,   -- % de Retención
      piretren IN NUMBER,   -- Importe de Retención
      piconren IN NUMBER,   -- Importe con Retención (NETO)
      pibasren IN NUMBER,   -- Base de Retención
      pcbancar IN VARCHAR2,   -- CCC donde se ingresa el pago
      pestmort IN NUMBER,   -- 0-Esta vivo 1-Esta muerto
      pproceso IN NUMBER DEFAULT NULL,
      idpago OUT NUMBER,
      pctipban IN NUMBER,
      pnsinies IN VARCHAR2 DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL,
      pctipdes IN NUMBER DEFAULT NULL)   --pkey de pagos renta a la que corresponde ese pago
      RETURN NUMBER;

   FUNCTION graba_param(wnsesion IN NUMBER, wparam IN VARCHAR2, wvalor IN NUMBER)
      RETURN NUMBER;

   FUNCTION borra_param(wnsesion IN NUMBER)
      RETURN NUMBER;

   FUNCTION ver_mensajes(nerr IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE borra_mensajes;

   PROCEDURE borra_tmp_pagosrenta;

   FUNCTION vto_aportaciones(pfefecto IN DATE, pusuario IN VARCHAR2, pcidioma IN NUMBER)
      RETURN NUMBER;

   FUNCTION vto_rentas(pfefecto IN DATE)   -- Fecha
      RETURN NUMBER;

-- ****************************************************************
-- anula_rec
-- Busca los recibos que se han pagado para extornar o generados
-- para in pfecha: Fecha
--param in pseguro: Seguro
-- param in secren : srecren
-- ****************************************************************
   FUNCTION anula_rec(
      pfecha IN DATE,   -- Fecha en que se ha informado la muerte
      pseguro IN NUMBER,   -- Clave del Seguro
      psrecren IN NUMBER DEFAULT NULL)   --Por si se quiere precisar a un recibo
      RETURN NUMBER;

-- *************************************************************************
--desanula_rec
-- Busca los recibos que se han anulado para desanularlos y recalcula Rentas
-- para in pfecha: Fecha
--param in pseguro: Seguro
-- param in secren : srecren
-- *************************************************************************
   FUNCTION desanula_rec(
      pfecha IN DATE,   -- Fecha en que se ha realizado suplemento
      pseguro IN NUMBER,   -- Clave del Seguro
      psrecren IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION siniestro_ren(
      pfecsini IN DATE,   -- Fecha del siniestro
      pfmuerte IN DATE,   -- Fecha de muerte
      psperson IN NUMBER,   -- Persona que muere
      pseguro IN NUMBER)   -- Clave del Seguro
      RETURN NUMBER;

   FUNCTION f_calc_ptipoint(
      psproduc IN NUMBER,
      reserva_bruta IN NUMBER,
      pfecha IN DATE,
      pinteres OUT NUMBER,
      pnduraint IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_busca_activo(
      psseguro IN NUMBER,
      piadquisi OUT NUMBER,
      ptcodact OUT VARCHAR2,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_renta_neta(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pfecha IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_rescat_net(
      psproduc IN NUMBER,
      psperson IN NUMBER,
      pfecha IN NUMBER,
      prescat IN NUMBER,
      prkm IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_coef_rescate(psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calc_rescate(
      psseguro IN NUMBER,
      pfecha IN NUMBER,
      psproduc IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'SOL')
      RETURN NUMBER;

   --JRH Función para buscar la reducción a una fecha. Devuelve un null si hay error.
   FUNCTION f_buscaprduccion(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN NUMBER,
      porigen IN NUMBER)
      RETURN NUMBER;

-- BUG 0013477 -  29/03/2011 - JMF
   -- ****************************************************************
--  FUNCTION f_calc_prestacion_pol
--         Funció que genera les prestacions d'una pòlissa
--       param in pproceso : Proceso
--       param in psseguro : Clave seguro
--       param in psperson  : Persona
--       param in psproduc :  Producto
--       param in prealpre :  -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
--       param in pf1paren : fecha primer pago
--       param in pfppren : Fecha próxima renta
--       param in pfecha : Fecha pago
--       param in pfefecto : Efecto póliza
--       param in pcbancar: Cuenta
--       param in ptiporen: Tipo renta ('R'egurlar,'E'xtra)
--       param in pnsinies : Siniestro
--         return            : 1 -> Tot correcte
--                             0 -> S'ha produit un error
-- ****************************************************************
   FUNCTION f_calc_prestacion_pol(
      pproceso IN NUMBER,   -- Nro. Proceso o Nro. Recibo
      pseguros IN NUMBER,   -- SSEGURO
      psperson IN NUMBER,   -- SPERSON 1er. Asegurado
      psproduc IN NUMBER,   -- SPRODUC
      prealpre IN NUMBER,   -- 0-Real o 1-Previo Ins tmp. o 2-Recalcula 3-Previo
      pf1pren IN DATE,
      pfppren IN DATE,   -- Fecha Proximo pago de renta
      pfefecto IN DATE,   -- Fecha
      pctabanc IN VARCHAR2,   -- Cuenta Bancaria
      ptiporen IN VARCHAR2,   -- Tipo de renta
      pnsinies IN VARCHAR2,
      pctipban IN NUMBER,
      pntramit IN NUMBER,
      pctipdes IN NUMBER,
      crevali IN NUMBER,
      prevali IN NUMBER,
      irevali IN NUMBER,
      pnpresta IN NUMBER)
      RETURN NUMBER;

   --JRH Función para buscar la renta bruta de una póliza. Devuelve un null si hay error.
   FUNCTION f_buscarentabruta(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN NUMBER,
      porigen IN NUMBER,
      ptiporen IN VARCHAR2 DEFAULT 'R'   -- Tipo de renta
                                      )
      RETURN NUMBER;

   --JRH Función que inserta en la tabla Planrentas. Devuelve un null si hay error.
   FUNCTION f_insertplanrentas(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   --JRH 01/2008 Estado de un pago a una fecha
   FUNCTION f_ult_estado_pago(psrecren IN NUMBER, pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   FUNCTION f_prov_sini(psseguro IN NUMBER)
      RETURN NUMBER;   --Nos da la provisión a la muerte de un asegurado

   FUNCTION f_haypagaextra(psproduc IN NUMBER, pmesextra IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_llenarnmesesextra(
      penero IN NUMBER,
      pfebrero IN NUMBER,
      pmarzo IN NUMBER,
      pabril IN NUMBER,
      pmayo IN NUMBER,
      pjunio IN NUMBER,
      pjulio IN NUMBER,
      pagosto IN NUMBER,
      pseptiembre IN NUMBER,
      poctubre IN NUMBER,
      pnoviembre IN NUMBER,
      pdiciembre IN NUMBER)
      RETURN VARCHAR2;

   -- NMM.24735.03/2013.i
   FUNCTION f_ompleimesosextra(
      pgener IN NUMBER,
      pfebrer IN NUMBER,
      pmars IN NUMBER,
      pabril IN NUMBER,
      pmaig IN NUMBER,
      pjuny IN NUMBER,
      pjuliol IN NUMBER,
      pagost IN NUMBER,
      psetembre IN NUMBER,
      poctubre IN NUMBER,
      pnovembre IN NUMBER,
      pdesembre IN NUMBER)
      RETURN VARCHAR2;

   -- NMM.24735.03/2013.f
   FUNCTION insertar_historico(psrecren IN NUMBER)
      RETURN NUMBER;

/* JGM - Bug --10297 -- F_get_ProdRentas
Nueva función de la capa lógica que devolverá los productos parametrizados con prestación rentas.

Parámetros
1. pcempres IN NUMBER
2. pcramo IN NUMBER
3. psproduc IN NUMBER
4. pidioma IN NUMBER
5. psquery OUT VARCHAR2*/
   FUNCTION f_get_prodrentas(
      pcempres IN NUMBER,
      pcramo IN VARCHAR2,
      psproduc IN NUMBER,   -- Sequence del producto
      pcidioma IN NUMBER,   -- Idioma
      psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Función que seleccionará información sobre los pagos renta dependiendo de los parámetros de entrada
      param in pcempres    : Id. de empresa
      param in pcramo      : Id. de ramo
      param in psproduc    : Id. de producto
      param in pnpoliza    : Id. de póliza
      param in pncertif    : Num. de certificado
      param in pcidioma    : Cod. idioma
      param out psquery    : Query a ejecutar
      return               : 0 -> Todo correcto
                             1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
  *************************************************************************/
   FUNCTION f_get_consultapagos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Función que recuperará la edad de un asegurado
      param in psseguro      : Id. de seguro
      param in pnriesgo      : Id. de riesgo
      param out pedad        : Edad asegurado
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_edadaseg(psseguro IN NUMBER, pnriesgo IN NUMBER, pedad OUT NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Función que recuperará los datos de renta de una póliza
      param in psseguro      : Id. de seguro
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_dat_renta(psseguro IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Función que recuperará los pagos renta de una póliza
      param in psseguro      : Id. de seguro
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
 *************************************************************************/
   FUNCTION f_get_pagos_renta(psseguro IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Función que recuperará el detalle del pago renta de una póliza
      param in psseguro      : Id. de seguro
      param in psrecren      : Id del recibo del pago de la renta
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_detpago_renta(
      psseguro IN NUMBER,
      psrecren IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Función que recuperará el detalle del pago renta de una póliza
      param in psrecren      : Id del recibo del pago de la renta
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_dat_polren(psrecren IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Función que recuperará los movimientos del recibo de un pago renta
      param in psrecren      : Id del recibo del pago de la renta
      param in pcidioma      : Cod. de idioma
      param out psquery      : Query a ejecutar
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error

     Bug 10499  02/07/2009  AMC
   *************************************************************************/
   FUNCTION f_get_mov_recren(psrecren IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
      Función validará las fechas calculadas y las corregirá si es posible
      param in pfecha      : fecha a validar
      return               : fecha correcta

     Bug 0014658  03/06/2010  JGR  CRE998- Parametrizar día de pago en Rentas Irregulares
   *************************************************************************/
   FUNCTION f_valida_date(pfecha IN VARCHAR2)
      RETURN DATE;

/*************************************************************************
      Funció que calcula el rendiment del capital mobiliari d'un rescat
      (Aquest funció realment la va afegir J.Ramiro)
      param in psseguro      : seguro
      param in pnpagos       : n.pagos
      param in prescat       : rescat
      param in pfecha        : data proces
      param in pnriesgo      : risc
      param in pcmotsin      : Indicamos si es rescate total o parcial , y el valor del rescate total en
      param in piresctot     : caso de que sea un parcial
      param in ptablas       : tablas
      return                 : 0 -> Todo correcto
                               1 -> Se ha producido un error
     Bug 0014658  03/06/2010  JGR  CRE998- Parametrizar día de pago en Rentas Irregulares
   *************************************************************************/
   FUNCTION f_rkm_rescate(
      psseguro IN NUMBER,
      pnpagos IN NUMBER,
      prescat IN NUMBER,
      pfecha IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotsin IN NUMBER DEFAULT 4,
      piresctot IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

 -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
-- BUG 16217 - 09/2010 - JRH  -  Cuadro de procisiones
    /*************************************************************************

       f_gen_evoluprovmatseg

       Cálculo del cuadro de rescates

       param in psseguro          : Sseguro
       param in pnmovimi          : Número movimiento
       param in  ptablas : 1 EST, 2 SEG
       return                     : 0 o diferente de 0 si hay error
   *************************************************************************/
   FUNCTION f_gen_evoluprovmatseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN NUMBER DEFAULT 2)
      RETURN NUMBER;

-- Fi BUG 16217 - 09/2010 - JRH  -  Cuadro de procisiones
 -- Fi BUG 0015669 - 08/2010 - JRH

   -- BUG 17005 - 15/12/2010 - APD  -  Se crea la funcion f_capitaliza_rvi
    /*************************************************************************

       f_capitaliza_rvi

       Cálculo de la capitalización aplicada en el modelo fiscal 189

       param in psegurosren       : Sseguro
       param in pfcalcul          : Fecha fin anualidad
       return                     : 0 o diferente de 0 si hay error
   *************************************************************************/
   FUNCTION f_capitaliza_rvi(psseguro IN NUMBER, pfcalcul IN DATE)
      RETURN NUMBER;

-- Fin BUG 17005 - 15/12/2010 - APD

   /*************************************************************************
      Function f_act_pago
      param in psrecren      : Id del recibo del pago de la renta
      param in pibase
      param in ppretenc
      param in pisinret
      param in piretenc
      param in piconret
      param in pctipban
      param in pnctacor
      return                 : 0 -> Todo correcto
                               9901068 -> Se ha producido un error
     --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pago(
      psrecren IN NUMBER,
      pibase IN NUMBER,
      ppretenc IN NUMBER,
      pisinret IN NUMBER,
      piretenc IN NUMBER,
      piconret IN NUMBER,
      pctipban IN NUMBER,
      pnctacor IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_get_consultapagos

    param in pcempres
    param in psproduc
    param in pnpoliza
    param in pncertif
    param in pcestado
    param out psquery
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_get_consultapagosrenta(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcestado IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_act_pagorenta

    param in psrecren
    param in pctipban
    param in pcuenta
    param in pbase
    param in pporcentaje
    param in pbruto
    param in pretencion
    param in pneto
    param in pestpag
    param in pfechamov
    param out mensajes OUT T_IAX_MENSAJES
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_act_pagorenta(
      psrecren IN NUMBER,
      pctipban IN NUMBER,
      pcuenta IN VARCHAR2,
      pbase IN NUMBER,
      pporcentaje IN NUMBER,
      pbruto IN NUMBER,
      pretencion IN NUMBER,
      pneto IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Funció f_act_pagorenta

    param in pseguro
    Retorno :  number

    --BUG 13477 - JTS - 15/03/2010
   *************************************************************************/
   FUNCTION f_bloq_proxpagos(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_distribuir_inversion_shw(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pccalint IN NUMBER,
      psrecren IN NUMBER,
      pisinret IN NUMBER,
      pcmovimi IN NUMBER,
      pcmovimi_detalle IN NUMBER)
      RETURN NUMBER;
END pk_rentas;

/

  GRANT EXECUTE ON "AXIS"."PK_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_RENTAS" TO "PROGRAMADORESCSI";
