C used in nclreg.R
      subroutine nclreg_fortran(x, y, weights, n,m,start, etastart,
     +         mustart, offset, nlambda, lambda, alpha, 
     +         gam, standardize, penaltyfactor, maxit, eps, family,
     +         penalty, trace, beta, b0, yhat, iter,
     +         del, rfamily, B, s, los, pll, rescale, thresh, epsbino, 
     +         theta, cost)
      implicit none
      integer n,m,i,ii,k,j,jj,penalty,nlambda,family,standardize, maxit,
     +  trace, iter, rfamily, rescale, jk, activeset(m), stopit, m_act,
     +  AllocateStatus, DeAllocateStatus, varsel(m), varsel_old(m)
      double precision x(n, m), y(n), weights(n),start(m+1),etastart(n),
     +     mustart(n), offset(n), lambda(nlambda),
     +     alpha, gam, eps, penaltyfactor(m), thresh, epsbino,  theta,
     +     beta(m, nlambda), b0(nlambda), b0_1,
     +     yhat(n), d, del, lambda_i,
     +     fk_old(n), s, B, h(n), fk(n), a, los(iter,nlambda), 
     +     pll(iter, nlambda), cost, penval
      double precision, dimension(:, :), allocatable :: x_act
      double precision, dimension(:), allocatable :: start_act, beta_1,
     + penaltyfactor_act

      i=1
      b0_1=0
      stopit = 0
      m_act = m
      allocate(start_act(m_act+1), stat=AllocateStatus)
      if(AllocateStatus .NE. 0)then
              return
      endif
      allocate(penaltyfactor_act(m_act), stat=AllocateStatus)
      allocate(x_act(n, m), stat=AllocateStatus)
      if(AllocateStatus .NE. 0)then
              return
      endif
      call copymatrix(n, m, x, x_act)
      allocate(beta_1(m_act), stat=AllocateStatus)
      if(AllocateStatus .NE. 0)then
              return
      endif
      do 5 j=1, m
      beta_1(j)=0
5     continue
      call dcopy(m, start, 1, start_act, 1)
      call dcopy(m, penaltyfactor, 1, penaltyfactor_act, 1)
           do 101 j=1, m
           varsel_old(j)=j
           varsel(j)=j
101        continue
10    if(i .LE. nlambda)then
             if(trace .EQ. 1)then
             call intpr("i=", -1, i, 1)
             endif
       k = 1
       d = 10
500        if(d .GT. del .AND. k .LE. iter)then
C             if(trace .EQ. 1)then
               call intpr("  k=", -1, k, 1)
               call dblepr("     d=", -1, d, 1)
C             endif
           call dcopy(n, yhat, 1, fk_old, 1)
           call compute_h(rfamily, n, y, fk_old, s, B, h)
C          check if h has NAN value
           do 30 ii=1, n
            if(h(ii) .NE. h(ii))then
                    stopit = 1
                    exit
            endif
30         continue
            lambda_i = lambda(i)/B
           call glmreg_fit_fortran(x_act, h, weights,n,m_act,start_act, 
     +          etastart, mustart, offset, 1, lambda_i, alpha,
     +          gam, rescale, standardize, penaltyfactor_act, thresh,
     +          epsbino, maxit, eps, theta, family,  
     +          penalty, trace, beta_1, b0_1, yhat)
               call intpr("     ok after glmreg_fit_fortran", -1, 1, 1)
           call dcopy(n, yhat, 1, fk, 1)
           call find_activeset(m_act, beta_1, eps, activeset, jk)
               call intpr("     ok after find_activeset", -1, 1, 1)
C this activeset is relative to the current x_act, but how about
C relative to x instead? compute varsel for true index in x
               call intpr("     jk=", -1, jk, 1)
               call intpr("     m_act=", -1, m_act, 1)
           if(jk .NE. m_act)then
              deallocate(start_act, stat=DeAllocateStatus)
              allocate(start_act(jk+1), stat=AllocateStatus)
              start_act(1) = b0_1
              do ii=1, jk
                j=activeset(ii)
                start_act(ii+1)=beta_1(j)
              enddo
              do 35 j=1, jk
                 varsel(j)=varsel_old(activeset(j))
35            continue
               call intpr("     varsel=", -1, varsel, jk)
              do 351 j=1, jk
                 varsel_old(j)=varsel(j)
351            continue
              deallocate(beta_1, stat=DeAllocateStatus) 
              allocate(beta_1(jk), stat=AllocateStatus)
              deallocate(x_act, stat=DeAllocateStatus)
              allocate(x_act(n, jk), stat=AllocateStatus)
C             update x_act matrix
              do 55 jj=1, n
                 do 45 ii=1, jk
                  j = varsel(ii)
                  x_act(jj, ii) = x(jj, j)
  45             continue
  55          continue
              deallocate(penaltyfactor_act, stat=DeAllocateStatus)
              allocate(penaltyfactor_act(jk), stat=AllocateStatus)
              do 65 ii=1, jk
                  j = varsel(ii)
                  penaltyfactor_act(ii)=penaltyfactor(j)
65            continue
              m_act = jk
             else
               start_act(1) = b0_1
               do 100 j=1, m_act
                 start_act(j+1)=beta_1(j)
100            continue
             endif 

C           m_act = jk
C         needs some work when trace=1
           if(trace .EQ. 1)then
               call loss(n, y, fk, cost, rfamily, s, los(k, i))
               penval = 0.d0
               call penGLM(beta_1, m, lambda_i*penaltyfactor, alpha,
     +                    gam, penalty, penval)
               if(standardize .EQ. 1)then
                       pll(k, i)=los(k, i) + n*penval
                 else 
                       pll(k, i)=los(k, i) + penval
               endif
           endif
           a = 0
           do 120 ii=1, n
            a=a+(fk_old(i) - fk(i))**2
120         continue
            d = a
            k = k + 1
           goto 500
           endif
               call intpr("     ok below goto 500", -1, 1, 1)
               call intpr("     stopit", -1, stopit, 1)
               call intpr("     jk", -1, jk, 1)
               call intpr("     varsel", -1, varsel, jk)
               call dblepr("     beta_1", -1, beta_1, jk)
           if(stopit .EQ. 0)then
               if(jk .EQ. 0)then
                  i = nlambda + 1
               endif
               b0(i) = b0_1
               do 200 ii = 1, jk
                  j = varsel(ii)
C                 something wrong here: it is possible beta_1 has length
C                 m_act > jk, then how to update below?
                  beta(j, i) = beta_1(activeset(ii))
C                  beta(j, i) = beta_1(ii)
200            continue
               call intpr("     ok here", -1, 1, 1)
               call intpr("     activeset here", -1, activeset, jk)
               call dblepr("     beta_1", -1, beta_1, jk)
               i = i + 1
           else
              i = nlambda + 1
           endif 
      goto 10
      endif
      deallocate(beta_1, start_act, x_act, penaltyfactor_act)

      return
      end
