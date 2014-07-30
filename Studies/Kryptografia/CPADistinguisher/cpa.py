from random import choice
from subprocess import Popen, PIPE

def call_openssl(args, input):
	p = Popen(['openssl'] + args, bufsize=4096, stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True)
	p.stdin.write(input)
	p.stdin.close()
	result = p.stdout.read()
	p.stdout.close()
	errors = p.stderr.read()
	p.stderr.close()
	return result, errors

def encode(mode, key, message):
	return call_openssl(['enc', '-'+mode, '-k', key], message)

def decode(mode, key, ciphertext):
	return call_openssl(['enc', '-'+mode, '-k', key, '-d'], ciphertext)

def oracle(mode, key, messages):
	return encode(mode, key, choice(messages))

modes = """
		aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb       
		aes-256-cbc       aes-256-ecb       base64            bf                
		bf-cbc            bf-cfb            bf-ecb            bf-ofb            
		camellia-128-cbc  camellia-128-ecb  camellia-192-cbc  camellia-192-ecb  
		camellia-256-cbc  camellia-256-ecb  cast              cast-cbc          
		cast5-cbc         cast5-cfb         cast5-ecb         cast5-ofb         
		des               des-cbc           des-cfb           des-ecb           
		des-ede           des-ede-cbc       des-ede-cfb       des-ede-ofb       
		des-ede3          des-ede3-cbc      des-ede3-cfb      des-ede3-ofb      
		des-ofb           des3              desx              rc2               
		rc2-40-cbc        rc2-64-cbc        rc2-cbc           rc2-cfb           
		rc2-ecb           rc2-ofb           rc4               rc4-40            
		seed              seed-cbc          seed-cfb          seed-ecb          
		seed-ofb          zlib              
		""".split()

# test encoder

mode = modes[0]
key	 = 'pass'

m = 'hidden message'
c, e = encode(mode, key, m)
if e:
	print e
d, e = decode(mode, key, c)
if e:
	print e
print "m:", m, "c:", c, "d:", d