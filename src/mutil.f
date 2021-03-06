C***********matrix and vector product
C A(N) = B(N,M) * C(M)   
C input:
C N
C M
C B(N,M)
C C(M) is vector with length M

C output:
C vector A(N)
      SUBROUTINE MVECPROD(N,M,B,C,A)
      INTEGER N,M,I
      DOUBLE PRECISION B(N,M),C(M),A(N),U
      DO 10 I=1,N
         U=0.D0
         DO 5 J=1, M
         U= U+ B(I,J)*C(J)
    5 CONTINUE
         A(I)=U
   10 CONTINUE
      END

C copy a matrix
C input: x is an n x m matrix
C      y is the output and y=x
      subroutine copymatrix(n, m, x, y)
              implicit none
              integer i, j, n, m
              double precision x(n, m), y(n, m)

      do 100 j=1, m
       do 110 i=1, n
              y(i, j)=x(i, j)
 110   continue
 100  continue

              return
              end
