create or replace PACKAGE "PAC_PSU_CONF" IS
   /******************************************************************************
      NOMBRE:    pac_psu_conf
      PROPÓSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor       Descripción
      ---------  ----------  ---------  ------------------------------------
      1.0        07/03/2016  JAE        1. Creación del objeto.
      2.0        06/09/2016  NMM        2. Función f_reaseguro_back.
      3.0        02/11/2016  HRE        3. Función f_facultativo
      4.0                    KJSC       4. CONF-241 AT_TEC_CONF_10_ANULACIONV_V1.0_GAP_GTEC49
      5.0        29/10/2016  NMM        5. CONF-434. Desarrollo PSU.
      5.1        27/12/2016  NMM        5. CONF-434. Desarrollo PSU.
      5.2        12/06/2017  HRE        5. CONF-695. Tipologias de Reaseguro.  Se agrega
                                           funcion f_riesgo_restringido.
	  5.3        04/03/2019	 HB         8. IAXIS-2421: Al superar tope anual de régimen simplificado, permitir cambiar categoría tributaria
   ******************************************************************************/

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION F_TOMADOR_RESTRINGIDO
      PSU 125 (801125)Tomador aparece en lista interna
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   /*************************************************************************
      FUNCTION F_ASEGURADO_RESTRINGIDO
      PSU 130 (801130)Asegurado aparece en lista interna
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   -- Esta función agrupa las 2 anteriores.
   FUNCTION f_persona_lre(
      p_nsesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_tipo IN NUMBER,
      p_ctiplis  IN   NUMBER DEFAULT NULL)
      RETURN NUMBER;
  ---------------------------------------------------------------------
  -- Obtiene si el contrato previamente se anulo
  ---------------------------------------------------------------------
   FUNCTION f_contrato_prev_a(
      p_nsesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_origenpsu IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
  /*************************************************************************
      FUNCTION f_valida_cumul_max_ctgar

      param in pscontgar : Identificador contragarantía
      param in psperson  : Identificador persona
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_cumul_max_ctgar(psseguro IN NUMBER,
                                     psperson IN NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_reaseguro_back

      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_reaseguro_back( psseguro IN NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_duplicidad_riesgo: Valida duplicidad de riesgo
      PSU 155 (801155) Duplicidad Riesgos
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo(psproduc IN NUMBER,
                                psseguro IN NUMBER) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_facultativo: Controla si necesita Reaseguro Facultativo
      param IN p_nsesion   : Código de la sesion
      param IN psseguro    : Número identificativo interno de SEGUROS
      param IN p_fefecto   : Fecha de efecto
      param IN p_nmovimi   : Numero de Movimiento
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_facultativo(
      p_nsesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_fefecto IN NUMBER,
      p_nmovimi IN NUMBER)
      RETURN NUMBER;
   --
   -- NMM.CONF-434.i
   --
   /*************************************************************************
      FUNCTION F_ES_CONTRACTUAL_SALARIO
      param in pcgarant  : Identificador garantía
      return             : number
   *************************************************************************/
   FUNCTION F_ES_CONTRACTUAL_SALARIO ( psproduc IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_prec
      Vigencia supera niv delegación: Modalidad Derivado de Contrato - Precontractual
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega_prec( psseguro  IN      NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_contrac
      Vigencia supera niv delegación: Modalidad Derivado de Contrato - Contractual
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega_contrac( psseguro  IN      NUMBER, PCGARANT IN NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_pagosal
      Vigencia supera niv delegación: Modalidad Derivado de - Contrato Pago Salarios
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega_pagosal( psseguro  IN      NUMBER, PCGARANT IN NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_postcont
      Vigencia supera niv delegación: Modalidad Derivado de - Contrato Post Contractual
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega_postcont( psseguro  IN      NUMBER, PCGARANT IN NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_subfam
      Vigencia supera niv delegación: Subsidio Familiar Vivienda
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega_subfam( psseguro  IN      NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_displeg
      Vigencia supera niv delegación: Para Disposiciones Legales
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega_displeg( psseguro  IN      NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_caucileg
      Vigencia supera niv delegación: Para Cauciones judiciales
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega_caucileg( psseguro  IN      NUMBER)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega
      Vigencia supera nivel delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_vig_sup_niv_delega( psseguro IN NUMBER, PCGARANT IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_ries_abs_rel
      Riesgo Relativo o Absoluto aplicado supera Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_RIES_ABS_REL( PSSEGURO IN NUMBER, P_ABS_REL IN CHAR) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_valor_max_aseg
      PSU 30 (80130) Valor Asegurado supera Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VALOR_MAX_ASEG( PSSEGURO IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_cambio_tomador
      PSU 7006 (8017006) Cambio tomador supera Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CAMBIO_TOMADOR( PSSEGURO IN NUMBER, PSSEGPOL IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_retroactividad
      PSU  45 (80145)Retroactividad superior al Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_RETROACTIVIDAD( PSSEGURO IN NUMBER, PFEFECTO IN NUMBER, PNMOVIMI IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_tasa_aplicada
      PSU  10 (80110)Tasa aplicada supera Nivel de delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_TASA_APLICADA( PSSEGURO IN NUMBER, PCGARANT   IN NUMBER DEFAULT NULL) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_COMISION_APLICADA
      PSU  40 (80140) Comision aplicada supera Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_COMISION_APLICADA( PSSEGURO IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_NUEVA_CLAUSULA
      PSU 100 (801100)Nueva clausula para revisión
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_NUEVA_CLAUSULA( PSSEGURO IN NUMBER, PSSEGPOL IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_coaseguro
      PSU 105 (801105)Coaseguro
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_COASEGURO( PSSEGURO IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_SUBSIDIO_FAMI
      - PSU 110 (801110)Subsidio Familiar de Vivienda
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   /*************************************************************************
      FUNCTION F_DISP_LEGALES
      PSU 115 (801115)Disposiciones Legales
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   --
   /*************************************************************************
      FUNCTION F_PERSONA_NATURAL
      PSU 135 (801135)Tomador y/o Asegurado persona natural
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_PERSONA_NATURAL(PSSEGURO IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_DESC_COMERCIAL
      PSU 140 (801140)Descuento Comercial aplicado supera el máximo delegado
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_DESC_COMERCIAL( PSSEGURO IN NUMBER, PCGARANT IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_MARCA_AUTORIZ
      PSU 145 (801145)Marcas Autorización
      param in p_sseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_MARCA_AUTORIZ( P_SSEGURO IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_REASEG_ESPECIAL
      PSU 150 (801150)Reaseguro Especial
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_REASEG_ESPECIAL( PSSEGURO IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_RIESGO_DUPLIC
      PSU 155 (801155)Duplicidad Riesgos
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   /*************************************************************************
      FUNCTION PSU_TRACE
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   --
   PROCEDURE PSU_TRACE ( P1 IN VARCHAR2, P2 IN VARCHAR2, P3  IN VARCHAR2);
   --
   /*************************************************************************
      FUNCTION F_CAMBIO_ASEG_BENEF
      PSU 165 (801165) Cambio Asegurado y/o Beneficiario supera Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CAMBIO_ASEG_BENEF( PSSEGURO IN NUMBER, PSSEGPOL IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_COBERTURA_RESTRINGA
      PSU 170 (801170) Cobertura/ Amparo Restringido o Prohibido aplicada supera Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_COBERTURA_RESTRINGA( PSSEGURO IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_VALIDA_DEDUCIBLE
      PSU 175 (801175) Deducibles aplicados deben ser validados
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VALIDA_DEDUCIBLE ( --p_nsesion   IN NUMBER
                                 p_sseguro   IN NUMBER
                               , p_fecefe    IN NUMBER
                               , p_nmovimi   IN NUMBER
                               , p_nriesgo   IN NUMBER
                               , p_cgarant   IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION f_autoriz_gar
      PSU 170 (801170) Cobertura/Amparo Restringido o Prohibido supera Nivel de Delegación
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_autoriz_gar(
      p_nsesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_VIGENCIA_RC
      PSU 46 () Vigencia Productos Responsabilidad Civil
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIGENCIA_RC(psseguro IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_VIGENCIA_TRC
      PSU 46 () Vigencia Productos TODO RIESGO CONSTRUCCION
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIGENCIA_TRC(psseguro IN NUMBER) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_VIGENCIA_TRDM
      PSU 46 () Vigencia Productos TODO RIESGO DAÑOS MATERIALES
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIGENCIA_TRDM(psseguro IN NUMBER) RETURN NUMBER;
   --
   -- NMM.CONF-434.f
   --
   --
   /*************************************************************************
      FUNCTION F_CUMULO_ASEG
      PSU 46 () Cúmulo+valor asegurado supera nivel del perfil
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CUMULO_ASEG(psseguro IN NUMBER) RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_CUMULO_SUPERA_CLI
      PSU 46 () Cúmulo+valor asegurado supera el cupo asignado al tomador
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CUMULO_SUPERA_CLI(psseguro IN NUMBER) RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_CESION
      PSU () Devuelve la cesión si el coaseguro es cedido
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VALIDA_CESION(psseguro IN NUMBER) RETURN NUMBER;

   --CONF-747 Inicio
   --
   /*************************************************************************
      FUNCTION f_max_coasegurador
      PSU 804340 Máximo número permitido de Coaseguradores
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_MAX_COASEGURADOR(psseguro IN NUMBER) RETURN NUMBER;
   --
   --CONF-747 Fin
   /*************************************************************************
      FUNCTION f_riesgo_restringido
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_riesgo_restringido(psseguro IN NUMBER) RETURN NUMBER;

   --CONF-910 Inicio
   --
   /*************************************************************************
      FUNCTION f_fecha_fin_rea
      PSU 804345 Negocio con fecha mayor a fecha fin del contrato de reaseguro
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_FECHA_FIN_REA( psseguro IN NUMBER) RETURN NUMBER;
   --
   -- Inicio IAXIS-2421 04/03/2019
   FUNCTION F_VALIDA_REGIMEN(psseguro IN NUMBER) RETURN NUMBER;
   -- Fin IAXIS-2421 04/03/2019
   --
   /*************************************************************************/
   -- INICIO IAXIS-3186 03/04/2019
   FUNCTION f_valida_convenio (psseguro IN NUMBER) RETURN NUMBER;
   -- FIN IAXIS-3186 03/04/2019
   
END pac_psu_conf;