CREATE OR REPLACE FUNCTION f_comis_baja_amp(p_sseguro IN seguros.sseguro%TYPE,
                                            p_nrecibo IN recibos.nrecibo%TYPE) RETURN NUMBER IS
  /******************************************************************************
     NOMBRE:       P_COMIS_BAJA_AMP
  PROPÓSITO:    Procedimiento que permite ejecutar comisiones cuando hay una baja de amparo (CONF)
  REVISIONES:
  Ver        Fecha        Autor             Descripción
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2020  JLTS             1. Creación del package.
  2.0        15/04/2020  ECP              2. IAXIS-13779. Error Endoso BAja de Amparos
  ******************************************************************************/
  v_nmovimi     movseguro.nmovimi%TYPE;
  vpasexec      NUMBER := 1;
  v_error       NUMBER := 0;
  v_femisio     DATE;
  v_crespue9802 respuestas.crespue%TYPE;
  v_retorno     NUMBER := 0;
  CURSOR c_garant IS
    SELECT * FROM garanseg_baja_tmp g WHERE g.sseguro = p_sseguro;
BEGIN
  v_nmovimi := pac_iax_produccion.vnmovimi;
  vpasexec  := 10;
  v_error := pac_preguntas.f_get_pregunseg(p_sseguro, 1, 9802, 'POL', v_crespue9802);
  IF v_error = 0 THEN
    -- Se selecciona la fecha de la pregunta Certificado base a afectar (9802)
    vpasexec := 20;
    BEGIN
      SELECT trunc(r.femisio)
        INTO v_femisio
        FROM recibos r
       WHERE sseguro = p_sseguro
         AND nmovimi = v_crespue9802;
    EXCEPTION
      WHEN no_data_found THEN
        v_femisio := trunc(f_sysdate);
    END;
  ELSE
      v_femisio := trunc(f_sysdate); -- Ini IAXIS--13779 -- 15/04/2020
  END IF;
  vpasexec := 30;
  -- Se busca la garantía que se dió de baja.
  --
  FOR c_garant_r IN c_garant LOOP
    --
    INSERT INTO comrecibo
      SELECT nrecibo,
             rownum nnumcom,
             q1.cagente,
             q1.cestrec,
             q1.fmovdia,
             q1.fcontab,
             q1.icombru,
             q1.icomret,
             q1.icomdev,
             q1.iretdev,
             q1.nmovimi,
             q1.icombru_moncia,
             q1.icomret_moncia,
             q1.icomdev_moncia,
             q1.iretdev_moncia,
             q1.f_cambio,
             q1.cgarant,
             q1.icomcedida,
             q1.icomcedida_moncia,
             q1.ccompan,
             q1.ivacomisi,
             q1.cgeccia
        FROM (SELECT p_nrecibo nrecibo,
                     c.cagente,
                     f_estadorec(p_nrecibo, f_sysdate) cestrec,
                     v_femisio fmovdia,
                     v_femisio fcontab,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icombru * -1
                           ELSE
                            icombru
                         END) icombru,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icomret * -1
                           ELSE
                            icomret
                         END) icomret,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icomdev * -1
                           ELSE
                            icomdev
                         END) icomdev,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            iretdev * -1
                           ELSE
                            iretdev
                         END) iretdev,
                     v_nmovimi nmovimi,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icombru_moncia * -1
                           ELSE
                            icombru_moncia
                         END) icombru_moncia,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icomret_moncia * -1
                           ELSE
                            icomret_moncia
                         END) icomret_moncia,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icomdev_moncia * -1
                           ELSE
                            icomdev_moncia
                         END) icomdev_moncia,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            iretdev_moncia * -1
                           ELSE
                            iretdev_moncia
                         END) iretdev_moncia,
                     f_sysdate f_cambio,
                     cgarant,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icomcedida * -1
                           ELSE
                            icomcedida
                         END) icomcedida,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            icomcedida_moncia * -1
                           ELSE
                            icomcedida_moncia
                         END) icomcedida_moncia,
                     c.ccompan,
                     SUM(CASE
                           WHEN r.ctiprec = 9 THEN
                            ivacomisi * -1
                           ELSE
                            ivacomisi
                         END) ivacomisi,
                     NULL cgeccia
                FROM comrecibo c,
                     recibos   r
               WHERE c.nrecibo = r.nrecibo
                 AND EXISTS (SELECT *
                        FROM recibos r1
                       WHERE r1.sseguro = p_sseguro
                         AND EXISTS (SELECT *
                                FROM movseguro m
                               WHERE m.sseguro = r1.sseguro
                                 AND m.nmovimi = r1.nmovimi
                                 AND m.cmovseg != 52)
                         AND r1.nrecibo = c.nrecibo)
                 AND c.cgarant = c_garant_r.cgarant
               GROUP BY c.cagente,
                        c.ccompan,
                        c.cgarant
               ORDER BY nrecibo,
                        c.cagente,
                        nmovimi,
                        c.cgarant,
                        c.ccompan) q1;
  END LOOP;
  -- Se elimina la tabla que contiene las garantias dadas de baja insertadas en F_DETRECIBOS
  DELETE garanseg_baja_tmp t WHERE t.sseguro = p_sseguro;
  RETURN v_retorno;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'F_COMIS_BAJA_AMP', vpasexec, 'psseguro=' || p_sseguro || ' p_nrecibo=' || p_nrecibo,
                'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'v_error = ' || v_error);
    v_retorno := 89907102; --Error a insertar en la tabla COMRECIBO (Baja Amparo)
    RETURN v_retorno;
END f_comis_baja_amp;
/