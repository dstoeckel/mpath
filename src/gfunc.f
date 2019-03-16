C input: mu, family, epsbino
C output: eta
      subroutine gfunc(mu, n, family, epsbino, eta)
      integer :: family, n, i
      
      double precision :: mu(n), eta(n)
      do i=1, n
       if(family==1)then
         eta(i) = mu(i)
       else if(family==2)then
         if(1-mu(i) > epsbino .AND. mu(i) > epsbino)then
          eta(i)=dlog(mu(i)/(1-mu(i)))
         else 
          eta(i)=0
         endif
       else if(family==3 .OR. family==4)then
          eta(i)=dlog(mu(i))
       endif
      enddo

      return
      end
