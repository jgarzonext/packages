CREATE OR REPLACE FUNCTION F_GET_VALORES_BAJA_AMP(p_sseguro      IN seguros.sseguro%TYPE,
                                                  p_cgarant      IN garanseg.cgarant%TYPE,
                                                  p_nmovimi      IN movseguro.nmovimi%TYPE,
                                                  p_screen_recib IN NUMBER,
                                                  p_cop_ext      IN NUMBER) RETURN NUMBER IS
  /*
   *************************************************************************
   NOMBRE:       F_GET_VALORES_BAJA_AMP
   PROPÓSITO:    Procedimient per imprimir rebuts.
                 Recuperar informacion de la sumatoria del valor de los recibos anteriores para el
                 movimiento de baja de amparos (SUPL = 239)
                 param in p_sseguro  : numero del seguro
                 param in p_cgarant  : Garantia
                 param in p_nmovimi  : Nro de movimiento (suplemento)
                 param in p_screen_recib : Si es 1 es para pantalla (devuelve el iconcep) y retorna el iprianu del recibo (concepto 0 y 50), si es 2 se actualiza el recibo (iconcep_monpol) y retorna cero(0)
                 param in p_cop_ext : si deseamos que devuelva iconcep (1) e iconcep_monpol (2)
                 param in p_cconcep : concepto (Solo se requiere cuando se llama desde esta misma funcion "recursiva")
                 param out mensajes : mensajes de error
                 return             : valor del 1. iconcep o 2. iconcep_monpol o Error 103512
  
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2020  JLTS               1. Creación de la funcion
   2.0        19/01/2020  JLTS               2. IAXIS-3264:Recuperar informacion de la sumatoria del
                                                valor de los recibos anteriores para el movimiento de baja de
                                                amparos (SUPL = 239)
   *************************************************************************
  */
  v_ssegpol seguros.sseguro%TYPE;
  v_sseguro seguros.sseguro%TYPE;
  v_valor       detrecibos.iconcep%TYPE := 0;
  v_valor_ced   detrecibos.iconcep%TYPE := 0;
  v_valor_total detrecibos.iconcep%TYPE := 0;
  v_nrecibo     recibos.nrecibo%TYPE;
  v_femisio     detrecibos.fcambio%TYPE;
  v_retorno     NUMBER := 0;
  vparam        VARCHAR2(500) := 'P_SSEGURO =' || p_sseguro || ' P_CGARANT=' || p_cgarant || ' P_NMOVIMI=' || p_nmovimi ||
                                 ' P_SCREEN_RECIB=' || p_screen_recib || ' P_COP_EXT=' || p_cop_ext;
  vobjectname   VARCHAR2(100) := 'F_GET_VALORES_BAJA_AMP';
  vpasexec      NUMBER := 10;
  v_tlastrec    pac_adm.rrecibo;

  v_crespue9802 pregunseg.crespue%TYPE;
  v_error       NUMBER := 0;
  error_exception EXCEPTION; 
  FUNCTION f_get_valor(w_sseguro seguros.sseguro%TYPE,
                       w_cgarant garanseg.cgarant%TYPE,
                       w_nmovimi movseguro.nmovimi%TYPE,
                       w_cconcep detrecibos.cconcep%TYPE,
                       w_cop_ext NUMBER) RETURN NUMBER IS
    v_iconcep        detrecibos.iconcep%TYPE;
    v_iconcep_monpol detrecibos.iconcep_monpol%TYPE;
    v_valor          detrecibos.iconcep_monpol%TYPE;
  BEGIN
    SELECT SUM(nvl(CASE
                     WHEN r.ctiprec = 9 THEN
                      (d.iconcep) * -1
                     ELSE
                      d.iconcep
                   END, 0)) iconcep,
           SUM(nvl(CASE
                     WHEN r.ctiprec = 9 THEN
                      (d.iconcep_monpol) * -1
                     ELSE
                      d.iconcep_monpol
                   END, 0)) iconcep_monpol
      INTO v_iconcep,
           v_iconcep_monpol
      FROM detrecibos d,
           recibos    r
     WHERE r.nrecibo = d.nrecibo
       AND r.sseguro = nvl(w_sseguro, r.sseguro)
       AND r.nmovimi < w_nmovimi
       AND d.cgarant = nvl(w_cgarant, d.cgarant)
       AND d.cconcep = nvl(w_cconcep, d.cconcep)
       AND d.nriesgo = 1
       AND EXISTS (SELECT *
              FROM movseguro m
             WHERE m.sseguro = r.sseguro
               AND m.nmovimi = r.nmovimi
               AND m.cmovseg != 52);
    IF w_cop_ext = 1 THEN
      v_valor := v_iconcep;
    ELSE
      v_valor := v_iconcep_monpol;
    END IF;
    RETURN v_valor;
  
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1;
  END f_get_valor;

BEGIN
  vpasexec  := 10;
  v_sseguro := nvl(p_sseguro, pac_iax_produccion.poliza.det_poliza.sseguro);
  v_ssegpol := pac_iax_produccion.poliza.det_poliza.ssegpol;
  --
  IF p_screen_recib = 1 THEN
    p_control_error('JLTS', 'F_GER_VALORES_BAJA_AMP',
                    'Solo para pantalla vparam ' || vparam || ' - ' || dbms_utility.format_call_stack);

    vpasexec := 20;
    v_valor  := f_get_valor(v_ssegpol, p_cgarant, p_nmovimi, 0, p_cop_ext);
    --
    vpasexec    := 30;
    v_valor_ced := f_get_valor(v_ssegpol, p_cgarant, p_nmovimi, 50, p_cop_ext);
    --
    vpasexec      := 40;
    v_valor_total := nvl(v_valor, 0) + nvl(v_valor_ced, 0);
    --
    p_control_error('JLTS', 'F_GET_VALORES_BAJA_AMP', 'v_valor (iconcep_monpol)=' || v_valor_total);
    v_retorno := v_valor_total;
  ELSE
    p_control_error('JLTS', 'F_GER_VALORES_BAJA_AMP', 'Solo para el recibo ' || vparam || ' - ' || dbms_utility.format_call_stack);
    -- Deberá actualizar los datos de la tabla 
    vpasexec := 50;
    v_error  := pac_preguntas.f_get_pregunseg(v_ssegpol, 1, 9802, 'POL', v_crespue9802);
    IF v_error = 0 THEN
      vpasexec := 55;
      --Se revisa el último recibo
      v_tlastrec := pac_adm.f_get_last_rec(v_ssegpol);
      v_nrecibo  := v_tlastrec.nrecibo;
      vpasexec   := 60;
      -- Se selecciona la fecha de la pregunta Certificado base a afectar (9802)
      SELECT trunc(r.femisio)
        INTO v_femisio
        FROM recibos r
       WHERE sseguro = v_ssegpol
         AND nmovimi = v_crespue9802;
    ELSE
      RAISE error_exception;
    END IF;
    vpasexec := 70;
    -- Se actualiza el detalle del recibo con los datos de la sumatorioa de los movimientos anteriores

    MERGE INTO detrecibos x
    USING (SELECT SUM(nvl(CASE
                      WHEN r.ctiprec = 9 THEN
                       (d.iconcep_monpol) * -1
                      ELSE
                       d.iconcep_monpol
                    END, 0)) iconcep_monpol,
            d.cconcep,
            d.cgarant,
            d.nriesgo
             FROM detrecibos d,
                  recibos    r
            WHERE r.nrecibo = d.nrecibo
              AND r.sseguro = v_ssegpol
              AND r.nmovimi < p_nmovimi
              AND d.nriesgo = 1
              AND EXISTS (SELECT *
                     FROM movseguro m
                    WHERE m.sseguro = r.sseguro
                      AND m.nmovimi = r.nmovimi
                      AND m.cmovseg != 52)
            GROUP BY d.cconcep,
                     d.cgarant,
                     d.nriesgo) y
    ON (x.nrecibo = v_nrecibo AND x.cconcep = y.cconcep AND x.cgarant = y.cgarant AND x.nriesgo = y.nriesgo)
    WHEN MATCHED THEN
      UPDATE
         SET x.iconcep_monpol = y.iconcep_monpol, 
             x.fcambio        = v_femisio;
    --p_control_error('JLTS', 'F_GET_VALORES_BAJA_AMP', SQL%ROWCOUNT || ' rows affected...');
      
    SELECT nvl(d.iconcep, 0),
           nvl(d.iconcep_monpol, 0)
      INTO v_valor,
           v_valor_ced
      FROM detrecibos d
     WHERE d.nrecibo = v_nrecibo
       AND d.cgarant = p_cgarant
       AND d.cconcep IN (0, 50)
       AND d.nriesgo = 1;
    vpasexec      := 80;
    v_valor_total := v_valor + v_valor_ced;
    v_retorno := v_valor_total;
  END IF;
  RETURN v_retorno;
EXCEPTION
  WHEN error_exception THEN
    p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
    RETURN 0;
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
    RETURN 103512; -- Error al leer de la tabla DETRECIBOS
END F_GET_VALORES_BAJA_AMP;
/
