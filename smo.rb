class Array
  #矩阵转置
  def T
    m=self.size
    n=0
    if m>0
      n=self[0].size
    end
    if m<1||n<1
      raise ArgumentError
    end
    a=Array.new(n){Array.new(m)}
    for i in 0..n-1
      for j in 0..m-1
        a[i][j]=self[j][i]
      end
    end
    return a
  end
  #矩阵乘法
  def multiply a
    m=self.size
    n=0
    if m>0
      n=self[0].size
    end
    if a.length!=n
      raise ArgumentError
    end
    if a[0].length<1
      raise ArgumentError
    end
    h=a[0].length
    newMatrix=Array.new(m){Array.new(h)}
    for i in 0..m-1
      for j in 0..h-1
        count=0
        for s in 0..n-1
          count+=self[i][s]*a[s][j]
        end
        newMatrix[i][j]=count
      end
    end
    if m==1&&h==1
      return newMatrix[0][0].to_f
    else
      return newMatrix
    end
  end
  #返回指定的行列或元素
  def select(i,j)
    @m=self.size
    @n=0
    if @m>0
     @n=self[0].size
    end
    if i==':'&&j==':'
      return self
    elsif i==':'&&j>=0&&j<@n
      array=Array.new(@m){Array.new(1)}
      for s in 0..@m-1
        array[s][0]=self[s][j]
      end
      return array
    elsif j==':'&&i>=0&&i<@m
      array=Array.new(1){Array.new(@n)}
      for s in 0..@n-1
        array[0][s]=self[i][s]
      end
      return array
    elsif i>=0&&i<@m&&j>=0&&j<@n
      return self[i][j]
    else
      raise ArgumentError
    end
  end
  #向量相乘
  def vectormultiply a
    if self.length==a.length&&a.length>0
      if self[0].length==a[0].length&&a[0].length>0
        l=Array.new(self.length){Array.new(self[0].length)}
        for i in 0..self.length-1
          for j in 0..self[0].length-1
            l[i][j]=self[i][j]*a[i][j]
          end
        end
        return l
      end
    end
    raise ArgumentError
  end
  #生成0矩阵
  def zeros(i,j)
    array=Array.new(i){Array.new(j,0)}
    return array
  end
  #生成非0矩阵
  def nonzero
    nonzeroCount=0
    array1=Array.new
    array2=Array.new
    if self.length>0&&self[0].length>0
      for i in 0..self.length-1
        for j in 0..self[0].length-1
          if self[i][j]>0
            nonzeroCount+=1
            array1.insert(i)
            array2.insert(j)
          end
        end
      end
      a=Array.new(2){Array.new(nonzeroCount)}
      a[0]=array1
      a[1]=array2
      return a
    end
  end
  #改变某一行的值
  def set(i,j)
    if self[i].length==j.length
      self[i]=j
    end
  end
end
class Svmmlia
  attr_accessor :dataMatIn
  attr_accessor :classLabels
  def loadDataSet xLabel,fileName
    @dataMatIn=Array.new
    @classLabels=Array.new
    a=Array.new
    File.open(xLabel,'r') do |file|
      count=0
      while line=file.gets
        count+=1
        line.force_encoding("UTF-8")
        lineArr=line.split(' ')
        a.insert(a.length,lineArr[0])
        if count==200
          break
        end
      end
    end
    File.open(fileName,'r') do |file|
      count=0
      while line=file.gets
        count+=1
        line.force_encoding("UTF-8")
        lineArr=line.split(' ')
        if lineArr[0]=='0'
          @classLabels.insert(@classLabels.length,[1])
        else
          @classLabels.insert(@classLabels.length,[-1])
        end
        charNum=Array.new
        for i in 0..a.length-1
           charNum.insert(charNum.length,scount(lineArr[1],a[i]))
        end
        @dataMatIn.insert(@dataMatIn.length,charNum)
        #@dataMatIn.insert(@dataMatIn.length,[lineArr[0].to_f,lineArr[1].to_f])
        #@classLabels.insert( @classLabels.length,[lineArr[2].to_f])
        if count==200
          break
        end
      end
    end
    puts "文件读取完毕,doc and Item矩阵准备完毕"
    return @dataMatIn,@classLabels
  end
  def scount str,str1
    arr=str.split(str1)
    return arr.length-1
  end
  def selectJrand(i,m)
    j=i
    seed=Random.new
    while j==i
      j=seed.rand(m)
    end
    return j
  end
  def clipAlpha aj,h,l
    if aj>h
      aj=h
    end
    if l>aj
      aj=l
    end
    return aj
  end
end
class SMO
  def smoSimple(dataMatIn,classLabels,c,toler,maxIter)
       @dataMatrix=dataMatIn
       @labelMat=classLabels.T
       @m=@dataMatrix.size
       @n=@dataMatrix[0].size
       @eCache=Array.new(@m){Array.new(@n,0)}
       @b=0
       @alphas=Array.new.zeros(@m,1)
       iter=0#限定最大迭代次数
       while iter<maxIter
         alphaPairsChanged=0
         for i in 0..@m-1
            gxi=@alphas.vectormultiply(@labelMat.T).T.multiply(@dataMatrix.multiply(@dataMatrix.select(i,':').T)).to_f+@b
            ei=gxi-@labelMat[0][i].to_f
            if (@labelMat[0][i].to_f*ei<-toler&&@alphas[i][0]<c)||(@labelMat[0][i].to_f*ei>toler&&@alphas[i][0]>0)
                j,ej=selectJ(i,ei)
                alphaiold=@alphas[i][0]
                alphajold=@alphas[j][0]
                if @labelMat[0][i]!=@labelMat[0][j]
                    l=max(0,@alphas[j][0]-@alphas[i][0])
                    h=min(c,c+@alphas[i][0]+@alphas[j][0])
                else
                  l=max(0,@alphas[i][0]+@alphas[j][0]-c)
                  h=min(c,@alphas[j][0]+@alphas[i][0])
                end
                #上下界相同
                if l==h
                  next
                end
                eta=2.0*@dataMatrix.select(i,':').multiply(@dataMatrix.select(j,':').T) -@dataMatrix.select(i,':').multiply(@dataMatrix.select(i,':').T)-@dataMatrix.select(j,':').multiply(@dataMatrix.select(j,':').T)
                if eta>=0
                  next
                end
                @alphas[j][0]-=@labelMat[0][j]*(ei-ej)/eta
                @alphas[j][0]=Svmmlia.new.clipAlpha(@alphas[j][0], h, l)
                updateEk(j)
                if (@alphas[j][0]-alphajold).abs<0.00001
                  next
                end
                @alphas[i][0]+=@labelMat[0][j]*@labelMat[0][i]*(alphajold-@alphas[j][0])
                updateEk(i)
                b1=@b-ei-@labelMat[0][i]*(@alphas[i][0]-alphaiold)*@dataMatrix.select(i,':').multiply(@dataMatrix.select(i,':').T)-@labelMat[0][j]*(@alphas[j][0]-alphajold)*@dataMatrix.select(i,':').multiply(@dataMatrix.select(j,':').T)
                b2=@b-ej-@labelMat[0][i]*(@alphas[i][0]-alphaiold)*@dataMatrix.select(i,':').multiply(@dataMatrix.select(j,':').T)-@labelMat[0][j]*(@alphas[j][0]-alphajold)*@dataMatrix.select(j,':').multiply(@dataMatrix.select(j,':').T)
               if 0<@alphas[i][0]&&c>@alphas[i][0]
                   @b=b1
               elsif 0<@alphas[j][0]&&c>@alphas[j][0]
                   @b=b2
               else
                   @b=(b1+b2)/2.0
               end
              alphaPairsChanged+=1
            end
            if alphaPairsChanged==0
              iter+=1
            else
              iter=0
            end
         end
       end
    return @b,@alphas
  end
  def max a,b
    return a>b ? a:b
  end
  def min a,b
    return a>b ? b:a
  end
  def updateEk(k)
    gxk=@alphas.vectormultiply(@labelMat.T).T.multiply(@dataMatrix.multiply(@dataMatrix.select(k,':').T)).to_f+@b
    ek=gxk-@labelMat[0][k].to_f
    @eCache[k]=[1,ek]
  end
  def selectJ(i,ei)
     maxK=0
     maxDeltaE=0
     seed=Random.new
     ej=0
     @eCache[i]=[i,ei]
     validEcacheList=@eCache.select(':',0).nonzero[0]
     if validEcacheList.length>1
       validEcacheList.each do|a|
           if a==i
              next
           end
           gxk=@alphas.vectormultiply(@labelMat.T).T.multiply(@dataMatrix.multiply(@dataMatrix.select(a,':').T)).to_f+@b
           ek=gxk-@labelMat[0][a].to_f
           deltaE=(ei-ek).abs
           if deltaE>maxDeltaE
              maxK=a
              maxDeltaE=deltaE
              ej=ek
           end
       end
       return maxK,ej
     else
       j=seed.rand(i...@m)
       gxj=@alphas.vectormultiply(@labelMat.T).T.multiply(@dataMatrix.multiply(@dataMatrix.select(j,':').T)).to_f+@b
       ej=gxj-@labelMat[0][j].to_f
       return j,ej
     end
  end
end
class Test
     a=Svmmlia.new
     dataMatIn,classLabels=a.loadDataSet("C:/Users/Administrator/Desktop/讲义/网络数据挖掘大作业/tfidf文件.txt","C:/Users/Administrator/Desktop/讲义/网络数据挖掘大作业/带标签短信.txt")
     b,alphas=SMO.new().smoSimple(dataMatIn,classLabels,200, 0.0001,10000)
     t=""
     t+="b:"+b.to_s+"\n"
     for i in 0..alphas.size-1
       t+="alpha"+i.to_s+":"+alphas[i][0].to_s+"\n"
     end
     puts t
     afile=File.new("C:/Users/Administrator/Desktop/讲义/网络数据挖掘大作业/Answer.txt",'w')
     afile.syswrite(t)
     afile.close
end
