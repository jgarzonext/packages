--------------------------------------------------------
--  DDL for Package Body PAC_MD_CORRETAJE
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_CORRETAJE AS
   /******************************************************************************
      NOMBRE:      PAC_MD_CORRETAJE
      PROPÓSITO:   Contiene las funciones de gestión del Co-corretaje

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/09/2011   DRA               1. 0019069: LCOL_C001 - Co-corretaje
      2.0        17/07/2019   DFR               2. IAXIS-3591 Visualizar los importes del recibo de manera ordenada y sin repetir conceptos.
      3.0        14/09/2019   ECP               3. IAXIS-5149  Verificacin por qu no se esta ejecutando el proceso de cancelacin por no pago.
      4.0        05/03/2020   JRVG              4. IAXIS-12960 Se crea la función F_CORRETAJE
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_calcular_comision_corretaje(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcagente IN NUMBER,
      ptablas IN VARCHAR2,
      ppartici IN NUMBER,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'psseguro: ' || psseguro || ', pnriesgo: ' || pnriesgo || ', pnmovimi: '
            || pnmovimi || ', pcagente: ' || pcagente || ', ptablas: ' || ptablas
            || ', pfefecto: ' || pfefecto || ', pcramo: ' || pcramo || ', pcmodali: '
            || pcmodali || ', pctipseg: ' || pctipseg || ', pccolect: ' || pccolect
            || ', pcactivi: ' || pcactivi || ', ppartici: ' || ppartici;
      vobject        VARCHAR2(200) := 'PAC_MD_CORRETAJE.f_calcular_comision_corretaje';
      vnumerr        NUMBER := 0;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_corretaje.f_calcular_comision_corretaje(psseguro, pnriesgo, pnmovimi,
                                                             pfefecto, pcramo, pcmodali,
                                                             pctipseg, pccolect, pcactivi,
                                                             pcagente, ptablas, ppartici,
                                                             ppcomisi, ppretenc);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_calcular_comision_corretaje;
   --
   -- Inicio IAXIS-3591 17/07/2019       
   --
   /*******************************************************************************
   FUNCION f_leecorretaje
   Función que obtiene los importes de comisión del recibo inclusive si existe Co-corretaje
   param in psseguro   -> Número de seguro
   param in pnrecibo   -> Número de recibo
   return              -> Cursor con importes de comisión aplicados por agente
   ********************************************************************************/
   FUNCTION f_leecorretaje(psseguro IN NUMBER,
                           pnrecibo IN NUMBER, 
                           mensajes OUT t_iax_mensajes)
        RETURN SYS_REFCURSOR IS
        v_pasexec NUMBER(8) := 0;
        v_param   VARCHAR2(500) := 'pnrecibo: ' || pnrecibo||' psseguro: '||psseguro;
        v_object  VARCHAR2(200) := 'pac_md_corretaje.f_leecorretaje';
        v_squery  VARCHAR2(500);
        v_cursor  SYS_REFCURSOR;
     BEGIN
        --
        v_pasexec := 1;
        --
        --IF pac_corretaje.f_tiene_corretaje(psseguro) = 1 THEN
          --
          --
         /* v_squery := 'SELECT c.cagente AS cagente, pac_redcomercial.ff_desagente(c.cagente, 8, 0) as tdesage,'
                     ||'      SUM(icombru_moncia) as icombru '
                     || 'FROM comrecibo c '
                     ||'WHERE c.nrecibo ='||pnrecibo
                     ||'GROUP BY cagente';*/
                     -- Ini IAXIS-5149 -- ECP --03/12/2019
                 -- INI SGM IAXIS-5347 ERRORES EN VALORES DE COMISION
          v_squery := 'SELECT c.cagente AS cagente, pac_redcomercial.ff_desagente(c.cagente, 8, 0) as tdesage,'
                     ||'      ABS(sum(icombru_moncia)) AS icombru, '
		             ||'     abs(sum(NVL (c.ivacomisi, 0))) AS ivacomis  '
                     ||' FROM comrecibo c,recibos re '
                     ||' WHERE c.nrecibo = re.nrecibo '
		             ||' AND  c.nrecibo = '||pnrecibo
                 ||' AND c.nmovimi = (SELECT MAX (d.nmovimi) FROM comrecibo d WHERE d.nrecibo = c.nrecibo AND d.cagente = c.cagente) GROUP BY c.cagente';  
                 -- FIN SGM IAXIS-5347 ERRORES EN VALORES DE COMISION
                      -- Fin IAXIS-5149 -- ECP --03/12/2019                
        /*ELSE
         v_squery := 'SELECT r.cagente AS cagente, pac_redcomercial.ff_desagente(r.cagente, 8, 0) AS tdesage,'
                     ||' acc.icomisi as icombru,ivacomisi as ivacomis '
	                 ||'  FROM recibos r, age_comis_corretaje acc  '
	                 ||' 	WHERE r.sseguro = acc.sseguro  '
	                 ||'  AND r.nmovimi = acc.nmovimi   ' 
	                 ||'  AND r.nrecibo = '||pnrecibo;*/    
        /*  v_squery := 'SELECT r.cagente AS cagente, pac_redcomercial.ff_desagente(r.cagente, 8, 0) AS tdesage,'
                     ||'      v.icombru AS icombru '
                     || 'FROM recibos r, vdetrecibos_monpol v '
                     ||'WHERE r.nrecibo ='||pnrecibo
                     ||'  AND r.nrecibo = v.nrecibo'
                     ||'  AND v.icombru != 0';*/
       -- END IF;
        --
        
        v_pasexec := 2;
        --
        v_cursor := pac_iax_listvalores.f_opencursor(v_squery, mensajes);
        --
        v_pasexec := 4;
        --
        RETURN v_cursor;
     EXCEPTION
        WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Error: ' || SQLERRM);
           IF v_cursor%ISOPEN THEN
             CLOSE v_cursor;
           END IF;
           RETURN v_cursor;
     END f_leecorretaje;   
     --
     -- Fin IAXIS-3591 17/07/2019       
     --
     
   -- Inicio IAXIS-12960 05/03/2020      
   --
   /*******************************************************************************
    FUNCION f_corretaje
    Función que obtiene los valores de sucursal, participacion y intermediario lider del recibo cuando existe Co-corretaje
    param in pnrecibo   -> Número de recibo
    return              -> Cursor con valores de cada intermediario
    ********************************************************************************/ 
   FUNCTION f_corretaje(pnrecibo IN NUMBER, 
                        mensajes OUT t_iax_mensajes)
        RETURN SYS_REFCURSOR IS
        v_pasexec NUMBER(8) := 0;
        v_param   VARCHAR2(500) := 'pnrecibo: ' || pnrecibo;
        v_object  VARCHAR2(200) := 'pac_md_corretaje.f_corretaje';
        v_squery  VARCHAR2(500);
        v_cursor  SYS_REFCURSOR;
     BEGIN
        --
        v_pasexec := 1;
        
          v_squery := 'SELECT ag.cagente as agente,'
                       ||' pac_redcomercial.ff_desagente(ag.cagente, 8, 0) as tdesage,'
                       ||' pac_redcomercial.f_busca_padre(24, ag.cagente,null,null) as sucur,'
                       ||' pac_redcomercial.ff_desagente(pac_redcomercial.f_busca_padre(24,ag.cagente,null,null),8,8) as nomsucur,'
                       ||' ag.ppartici as partici,'
                       ||' ag.islider as lider' 
                       ||' FROM age_corretaje ag,recibos re'
                       ||' WHERE ag.sseguro = re.sseguro'
                       ||' AND ag.nmovimi = re.nmovimi'
                       ||' AND re.nrecibo = ' ||pnrecibo ;  
                 
        v_pasexec := 2;
        --
        v_cursor := pac_iax_listvalores.f_opencursor(v_squery, mensajes);
        --
        v_pasexec := 3;
        --
        RETURN v_cursor;
     EXCEPTION
        WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Error: ' || SQLERRM);
           IF v_cursor%ISOPEN THEN
             CLOSE v_cursor;
           END IF;
           RETURN v_cursor;
     END f_corretaje;   
     --
     -- Fin IAXIS-12960 05/03/2020      
     --
END pac_md_corretaje;

/