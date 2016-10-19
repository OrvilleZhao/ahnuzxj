class NMF
  attr_reader :w
  attr_reader :h
  attr_reader :r
  def initialize(n,m,v)
     @n=n
     @m=m
     @r=(n*m/(n+m))/2
     rand=Random.new
     @w=Array.new(n){Array.new(@r)}
     @h=Array.new(@r){Array.new(m)}
     @v=v
     for i in 0..@n-1
       for j in 0..@r-1
         @w[i][j]=rand.rand(20)
       end
     end
    for i in 0..@r-1
      for j in 0..@m-1
        @h[i][j]=rand.rand(20)
      end
    end
  end
  def ArrayTimes(a,n1,m1,b,n2,m2)
       if m1!=n2
         return ArgumentError
       else
         array=Array.new(n1){Array.new(m2)}
         for i in 0..n1-1
           for j in 0..m2-1
             count=0
             for p in 0..m1-1
               count+=a[i][p]*b[p][j]
             end
             array[i][j]=count.round(4)
           end
         end
         return array
       end
  end
  def Transposition(a,n,m)
    array=Array.new(m){Array.new(n)}
    for i in 0..m-1
      for j in 0..n-1
        array[i][j]=a[j][i]
      end
    end
    return array
  end
  def Euclidean
    for k in 0..200
          wt=Transposition(@w,@n,@r)
          wtv=ArrayTimes(wt,@r,@n,@v,@n,@m)
          wtw=ArrayTimes(wt,@r,@n,@w,@n,@r)
          wtwh=ArrayTimes(wtw,@r,@r,@h,@r,@m)
          for i in 0..@r-1
            for j in 0..@m-1
              if wtwh[i][j]!=0
               @h[i][j]=@h[i][j]*(wtv[i][j].to_f/wtwh[i][j].to_f)
              end
            end
          end
          ht=Transposition(@h,@r,@m)
          vht=ArrayTimes(@v,@n,@m,ht,@m,@r)
          wh=ArrayTimes(@w,@n,@r,@h,@r,@m)
          whht=ArrayTimes(wh,@n,@m,ht,@m,@r)
          for i  in 0..@n-1
            for j in 0..@r-1
              if whht[i][j]!=0
               @w[i][j]=@w[i][j]*(vht[i][j].to_f/whht[i][j].to_f)
              end
            end
          end
          if (k+1)%1==0
            wh=ArrayTimes(@w,@n,@r,@h,@r,@m)
            count=0
            for i in 0..19
              for j in 0..19
                count+=(@v[i][j].to_i-wh[i][j].to_i)*(@v[i][j].to_i-wh[i][j].to_i)
              end
            end
            puts (k+1).to_s+"次迭代误差为:"+count.to_s
          end
      end
  end
  def divergence
    wh=ArrayTimes(@w,@n,@r,@h,@r,@m)
    for i in 0..@n-1
      for j in 0..@r-1
          count1=0
          for p in 0..@m-1
            if wh[i][p]!=0
            count1+=@h[j][p]*@v[i][p]/wh[i][p]
            end
          end
          count2=0
          for p in 0..@m-1
            count2+=@h[j][p]
          end
         @w[i][j]=(@w[i][j]*(count1.to_f/count2.to_f)).round(4)
      end
    end
    for i in 0..@r-1
      for j in 0..@m-1
        count1=0
        for p in 0..@n-1
          if wh[p][j]!=0
          count1+=@w[p][i]*@v[p][j]/wh[p][j]
          end
        end
        count2=0
        for p in 0..@n-1
          count2+=@w[p][i]
        end
        @h[i][j]=(@h[i][j]*(count1.to_f/count2.to_f)).round(4)
      end
    end
  end
end
class Main
  rand=Random.new
  array=Array.new(20){Array.new(20)}
  for i in 0..19
    for j in 0..19
      array[i][j]=rand.rand(20)
    end
  end
  p=NMF.new(20,20,array)

  p.Euclidean
  puts "V矩阵为:"
  for i in 0..19
    for j in 0..19
      printf array[i][j].to_s+' '
    end
    puts ""
  end
  puts "W矩阵收敛为"
  for i in 0..19
    for j in 0..p.r-1
      printf p.w[i][j].round(4).to_s+' '
    end
    puts ""
  end
  puts "H矩阵收敛为"
  for i in 0..p.r-1
    for j in 0..19
      printf p.h[i][j].round(4).to_s+' '
    end
    puts ""
  end
end
