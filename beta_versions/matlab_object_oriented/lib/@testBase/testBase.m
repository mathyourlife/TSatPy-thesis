classdef testBase
  methods
    function self = testBase()
    end
    
    function r=assertMatchClass(self,a,b)
      if(strcmp(class(a),class(b)))
        r=1;
      else
        disp(sprintf('The class %s does not match the expected class %s',class(b),class(a)))
        r=0;
      end
    end
    
    function r=assertEquals(self,a,b,msg)
      if(nargin==3)
        msg = '(no test message)';
      end
      if(~self.assertMatchClass(a,b))
        r=0;
      end
      
      % Assume the test fails, check for success
      success=0;
      if(isnumeric(a) & isnumeric(b))
        if(strcmp(num2str(a),num2str(b)))
          success=1;
        end
      elseif(isa(a,'state') & isa(b,'state'))
        if (a == b)
          success=1;
        end
      elseif(isa(a,'bodyRate') & isa(b,'bodyRate'))
        if (a == b)
          success=1;
        end
      elseif(isa(a,'quaternion') & isa(b,'quaternion'))
        if (a == b)
          success=1;
        end
      elseif (isa(a,'cell') & isa(b,'cell'))
        if ((numel(a) == numel(b)) & (numel(setdiff(a,b)) == 0))
          success=1;
        end
      else
        if (numel(a) == numel(b))
          if (a==b)
            success=1;
          end
        end
      end
      
      if(success)
        r=1;
        disp(sprintf('... OK: %s',msg))
      else
        r=0;
        warning(msg);
        disp('**Expected')
        disp(a)
        disp('**Test Result')
        disp(b)
      end
    end
    
    function r=assertMatrices(self,a,b,msg)
      threshold = 1e-12;
      
      error = max(max(abs(a-b)));
      
      if error > threshold
        r=0;
        warning(msg)
        disp('**Expected')
        disp(a)
        disp('**Test Result')
        disp(b)
      else
        r=1;
        disp(sprintf('... OK: %s',msg))
      end
    end
    
    function r=assertLessThan(self,a,b,msg)
      if(nargin==3)
        msg = '(no test message)';
      end
      if (a<b)
        disp(sprintf('... OK: %s',msg))
        r=true;
      else
        r=false;
        warning(msg);
        disp('**Limit')
        disp(a)
        disp('**Test Result')
        disp(b)
      end
    end
    
    function r=assertLessThanOrEqual(self,a,b,msg)
      if(nargin==3)
        msg = '(no test message)';
      end
      if (a<=b)
        disp(sprintf('... OK: %s',msg))
        r=true;
      else
        r=false;
        warning(msg);
        disp('**Limit')
        disp(a)
        disp('**Test Result')
        disp(b)
      end
    end
    
    function r=assertGreaterThan(self,a,b,msg)
      if(nargin==3)
        msg = '(no test message)';
      end
      if (a>b)
        disp(sprintf('... OK: %s',msg))
        r=true;
      else
        r=false;
        warning(msg);
        disp('**Limit')
        disp(a)
        disp('**Test Result')
        disp(b)
      end
    end
    
    function r=assertGreaterThanOrEqual(self,a,b,msg)
      if(nargin==3)
        msg = '(no test message)';
      end
      if (a>=b)
        disp(sprintf('... OK: %s',msg))
        r=true;
      else
        r=false;
        warning(msg);
        disp('**Limit')
        disp(a)
        disp('**Test Result')
        disp(b)
      end
    end
    
    function r=assertBetween(self,a,b,c,msg)
      if(nargin==4)
        msg = '(no test message)';
      end
      comp = (c>=a & c<=b);
      if (sum(sum(comp)) == numel(comp))
        r=1;
        disp(sprintf('... OK: %s',msg))
      else
        r=0;
        warning(msg);
        disp('**Expected Between')
        disp(a)
        disp('And')
        disp(b)
        disp('**Test Result')
        disp(c)
      end
    end
    
    function r=assertMaxError(self,expected,actual,max_err_pcnt,msg)
      if(nargin==4)
        msg = '(no test message)';
      end
      
      max_error = max_err_pcnt / 100;
      if (isa(expected,'quaternion'))
        expected = [expected.vector' expected.scalar];
        actual = [actual.vector' actual.scalar];
      elseif (isa(expected,'bodyRate'))
        expected = expected.w';
        actual = actual.w';
      elseif (isa(expected,'state'))
        expected = [expected.q.vector' expected.q.scalar expected.w.w'];
        actual = [actual.q.vector' actual.q.scalar actual.w.w'];
      end
      
      errs = abs((actual - expected) ./ expected);
      errs(isnan(errs)) = 0;
      errs(isinf(errs)) = actual(isinf(errs));
      
      comp = errs <= max_error;
      
      if (sum(sum(comp)) == numel(expected))
        r=1;
        disp(sprintf('... OK: %s',msg))
      else
        r=0;
        warning(msg)
        disp('Actual')
        disp(actual)
        disp(sprintf('is outside the max error of %0.1f%% from the expected',max_err_pcnt))
        disp(expected)
        disp('% Error')
        disp(errs*100)
      end
      
    end
    
    function r=assertErrorMsg(self,expected,actual,msg)
      if(nargin==3)
        msg = '(no test message)';
      end
      if (isempty(strfind(actual,expected)))
        r=0;
        warning(msg)
        disp('**Actual')
        disp(actual)
        disp('**Expected')
        disp(expected)
      else
        r=1;
        disp(sprintf('... OK: %s',msg))
      end
      
    end
    
    function r=fail(self,msg)
      % Use this test case when a line of test code should never be
      % run such as following a line in a try catch that should
      % jump to the catch block.
      r=0;
      warning(msg)
    end
    
    function r=pass(self,msg)
      % Use this test case to pass a test.
      r=1;
      disp(sprintf('... OK: %s',msg))
    end
  end
end

