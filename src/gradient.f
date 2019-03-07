C### compute gradient w.r.t. u=margin y*f or u=y-f for nonconvex loss
C converted from R package bst R/gradient function
C input: family, u, s, no change
C output: g
C family: 
C    clossR: 1, closs: 2, gloss: 3, qloss: 4
C
      subroutine gradient(family, n, u, s, g)
      implicit none
      integer family, n, i
      double precision u(n), s, g(n), cval, pi

      if(family .EQ. 1)then
              do 10 i=1, n
              g(i) = u(i)/(s**2*dexp(u(i)**2/(2*s**2)))
10    continue 
      else if(family .EQ. 2)then
              cval = 1/(1 - dexp(-1/(2*s**2)))
              do 20 i=1, n
              g(i)=cval*(u(i)-1)/(s**2*dexp((1-u(i))**2/(2*s**2)))
20    continue 
      else if(family .EQ. 3)then
              do 30 i=1, n
              g(i)=-2**s*s*dexp(u(i))*(dexp(u(i))+1)**(-s-1)
30    continue 
      else if(family .EQ. 4)then
              pi = 3.14159
              do 40 i=1, n
              g(i) = -sqrt(2.0)/(dsqrt(pi)*s)*dexp(-u(i)**2/(2*s**2))
40    continue 
      endif

      return
      end

