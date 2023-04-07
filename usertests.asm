
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 10             	sub    $0x10,%esp
  printf(stdout, "iput test\n");
       6:	68 c8 3b 00 00       	push   $0x3bc8
       b:	ff 35 44 53 00 00    	push   0x5344
      11:	e8 6e 38 00 00       	call   3884 <printf>

  if(mkdir("iputdir") < 0){
      16:	c7 04 24 5b 3b 00 00 	movl   $0x3b5b,(%esp)
      1d:	e8 65 37 00 00       	call   3787 <mkdir>
      22:	83 c4 10             	add    $0x10,%esp
      25:	85 c0                	test   %eax,%eax
      27:	78 54                	js     7d <iputtest+0x7d>
    printf(stdout, "mkdir failed\n");
    exit();
  }
  if(chdir("iputdir") < 0){
      29:	83 ec 0c             	sub    $0xc,%esp
      2c:	68 5b 3b 00 00       	push   $0x3b5b
      31:	e8 59 37 00 00       	call   378f <chdir>
      36:	83 c4 10             	add    $0x10,%esp
      39:	85 c0                	test   %eax,%eax
      3b:	78 58                	js     95 <iputtest+0x95>
    printf(stdout, "chdir iputdir failed\n");
    exit();
  }
  if(unlink("../iputdir") < 0){
      3d:	83 ec 0c             	sub    $0xc,%esp
      40:	68 58 3b 00 00       	push   $0x3b58
      45:	e8 25 37 00 00       	call   376f <unlink>
      4a:	83 c4 10             	add    $0x10,%esp
      4d:	85 c0                	test   %eax,%eax
      4f:	78 5c                	js     ad <iputtest+0xad>
    printf(stdout, "unlink ../iputdir failed\n");
    exit();
  }
  if(chdir("/") < 0){
      51:	83 ec 0c             	sub    $0xc,%esp
      54:	68 7d 3b 00 00       	push   $0x3b7d
      59:	e8 31 37 00 00       	call   378f <chdir>
      5e:	83 c4 10             	add    $0x10,%esp
      61:	85 c0                	test   %eax,%eax
      63:	78 60                	js     c5 <iputtest+0xc5>
    printf(stdout, "chdir / failed\n");
    exit();
  }
  printf(stdout, "iput test ok\n");
      65:	83 ec 08             	sub    $0x8,%esp
      68:	68 00 3c 00 00       	push   $0x3c00
      6d:	ff 35 44 53 00 00    	push   0x5344
      73:	e8 0c 38 00 00       	call   3884 <printf>
}
      78:	83 c4 10             	add    $0x10,%esp
      7b:	c9                   	leave  
      7c:	c3                   	ret    
    printf(stdout, "mkdir failed\n");
      7d:	83 ec 08             	sub    $0x8,%esp
      80:	68 34 3b 00 00       	push   $0x3b34
      85:	ff 35 44 53 00 00    	push   0x5344
      8b:	e8 f4 37 00 00       	call   3884 <printf>
    exit();
      90:	e8 8a 36 00 00       	call   371f <exit>
    printf(stdout, "chdir iputdir failed\n");
      95:	83 ec 08             	sub    $0x8,%esp
      98:	68 42 3b 00 00       	push   $0x3b42
      9d:	ff 35 44 53 00 00    	push   0x5344
      a3:	e8 dc 37 00 00       	call   3884 <printf>
    exit();
      a8:	e8 72 36 00 00       	call   371f <exit>
    printf(stdout, "unlink ../iputdir failed\n");
      ad:	83 ec 08             	sub    $0x8,%esp
      b0:	68 63 3b 00 00       	push   $0x3b63
      b5:	ff 35 44 53 00 00    	push   0x5344
      bb:	e8 c4 37 00 00       	call   3884 <printf>
    exit();
      c0:	e8 5a 36 00 00       	call   371f <exit>
    printf(stdout, "chdir / failed\n");
      c5:	83 ec 08             	sub    $0x8,%esp
      c8:	68 7f 3b 00 00       	push   $0x3b7f
      cd:	ff 35 44 53 00 00    	push   0x5344
      d3:	e8 ac 37 00 00       	call   3884 <printf>
    exit();
      d8:	e8 42 36 00 00       	call   371f <exit>

000000dd <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      dd:	55                   	push   %ebp
      de:	89 e5                	mov    %esp,%ebp
      e0:	83 ec 10             	sub    $0x10,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      e3:	68 8f 3b 00 00       	push   $0x3b8f
      e8:	ff 35 44 53 00 00    	push   0x5344
      ee:	e8 91 37 00 00       	call   3884 <printf>

  pid = fork();
      f3:	e8 1f 36 00 00       	call   3717 <fork>
  if(pid < 0){
      f8:	83 c4 10             	add    $0x10,%esp
      fb:	85 c0                	test   %eax,%eax
      fd:	78 47                	js     146 <exitiputtest+0x69>
    printf(stdout, "fork failed\n");
    exit();
  }
  if(pid == 0){
      ff:	0f 85 a1 00 00 00    	jne    1a6 <exitiputtest+0xc9>
    if(mkdir("iputdir") < 0){
     105:	83 ec 0c             	sub    $0xc,%esp
     108:	68 5b 3b 00 00       	push   $0x3b5b
     10d:	e8 75 36 00 00       	call   3787 <mkdir>
     112:	83 c4 10             	add    $0x10,%esp
     115:	85 c0                	test   %eax,%eax
     117:	78 45                	js     15e <exitiputtest+0x81>
      printf(stdout, "mkdir failed\n");
      exit();
    }
    if(chdir("iputdir") < 0){
     119:	83 ec 0c             	sub    $0xc,%esp
     11c:	68 5b 3b 00 00       	push   $0x3b5b
     121:	e8 69 36 00 00       	call   378f <chdir>
     126:	83 c4 10             	add    $0x10,%esp
     129:	85 c0                	test   %eax,%eax
     12b:	78 49                	js     176 <exitiputtest+0x99>
      printf(stdout, "child chdir failed\n");
      exit();
    }
    if(unlink("../iputdir") < 0){
     12d:	83 ec 0c             	sub    $0xc,%esp
     130:	68 58 3b 00 00       	push   $0x3b58
     135:	e8 35 36 00 00       	call   376f <unlink>
     13a:	83 c4 10             	add    $0x10,%esp
     13d:	85 c0                	test   %eax,%eax
     13f:	78 4d                	js     18e <exitiputtest+0xb1>
      printf(stdout, "unlink ../iputdir failed\n");
      exit();
    }
    exit();
     141:	e8 d9 35 00 00       	call   371f <exit>
    printf(stdout, "fork failed\n");
     146:	83 ec 08             	sub    $0x8,%esp
     149:	68 75 4a 00 00       	push   $0x4a75
     14e:	ff 35 44 53 00 00    	push   0x5344
     154:	e8 2b 37 00 00       	call   3884 <printf>
    exit();
     159:	e8 c1 35 00 00       	call   371f <exit>
      printf(stdout, "mkdir failed\n");
     15e:	83 ec 08             	sub    $0x8,%esp
     161:	68 34 3b 00 00       	push   $0x3b34
     166:	ff 35 44 53 00 00    	push   0x5344
     16c:	e8 13 37 00 00       	call   3884 <printf>
      exit();
     171:	e8 a9 35 00 00       	call   371f <exit>
      printf(stdout, "child chdir failed\n");
     176:	83 ec 08             	sub    $0x8,%esp
     179:	68 9e 3b 00 00       	push   $0x3b9e
     17e:	ff 35 44 53 00 00    	push   0x5344
     184:	e8 fb 36 00 00       	call   3884 <printf>
      exit();
     189:	e8 91 35 00 00       	call   371f <exit>
      printf(stdout, "unlink ../iputdir failed\n");
     18e:	83 ec 08             	sub    $0x8,%esp
     191:	68 63 3b 00 00       	push   $0x3b63
     196:	ff 35 44 53 00 00    	push   0x5344
     19c:	e8 e3 36 00 00       	call   3884 <printf>
      exit();
     1a1:	e8 79 35 00 00       	call   371f <exit>
  }
  wait();
     1a6:	e8 7c 35 00 00       	call   3727 <wait>
  printf(stdout, "exitiput test ok\n");
     1ab:	83 ec 08             	sub    $0x8,%esp
     1ae:	68 b2 3b 00 00       	push   $0x3bb2
     1b3:	ff 35 44 53 00 00    	push   0x5344
     1b9:	e8 c6 36 00 00       	call   3884 <printf>
}
     1be:	83 c4 10             	add    $0x10,%esp
     1c1:	c9                   	leave  
     1c2:	c3                   	ret    

000001c3 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     1c3:	55                   	push   %ebp
     1c4:	89 e5                	mov    %esp,%ebp
     1c6:	83 ec 10             	sub    $0x10,%esp
  int pid;

  printf(stdout, "openiput test\n");
     1c9:	68 c4 3b 00 00       	push   $0x3bc4
     1ce:	ff 35 44 53 00 00    	push   0x5344
     1d4:	e8 ab 36 00 00       	call   3884 <printf>
  if(mkdir("oidir") < 0){
     1d9:	c7 04 24 d3 3b 00 00 	movl   $0x3bd3,(%esp)
     1e0:	e8 a2 35 00 00       	call   3787 <mkdir>
     1e5:	83 c4 10             	add    $0x10,%esp
     1e8:	85 c0                	test   %eax,%eax
     1ea:	78 39                	js     225 <openiputtest+0x62>
    printf(stdout, "mkdir oidir failed\n");
    exit();
  }
  pid = fork();
     1ec:	e8 26 35 00 00       	call   3717 <fork>
  if(pid < 0){
     1f1:	85 c0                	test   %eax,%eax
     1f3:	78 48                	js     23d <openiputtest+0x7a>
    printf(stdout, "fork failed\n");
    exit();
  }
  if(pid == 0){
     1f5:	75 63                	jne    25a <openiputtest+0x97>
    int fd = open("oidir", O_RDWR);
     1f7:	83 ec 08             	sub    $0x8,%esp
     1fa:	6a 02                	push   $0x2
     1fc:	68 d3 3b 00 00       	push   $0x3bd3
     201:	e8 59 35 00 00       	call   375f <open>
    if(fd >= 0){
     206:	83 c4 10             	add    $0x10,%esp
     209:	85 c0                	test   %eax,%eax
     20b:	78 48                	js     255 <openiputtest+0x92>
      printf(stdout, "open directory for write succeeded\n");
     20d:	83 ec 08             	sub    $0x8,%esp
     210:	68 58 4b 00 00       	push   $0x4b58
     215:	ff 35 44 53 00 00    	push   0x5344
     21b:	e8 64 36 00 00       	call   3884 <printf>
      exit();
     220:	e8 fa 34 00 00       	call   371f <exit>
    printf(stdout, "mkdir oidir failed\n");
     225:	83 ec 08             	sub    $0x8,%esp
     228:	68 d9 3b 00 00       	push   $0x3bd9
     22d:	ff 35 44 53 00 00    	push   0x5344
     233:	e8 4c 36 00 00       	call   3884 <printf>
    exit();
     238:	e8 e2 34 00 00       	call   371f <exit>
    printf(stdout, "fork failed\n");
     23d:	83 ec 08             	sub    $0x8,%esp
     240:	68 75 4a 00 00       	push   $0x4a75
     245:	ff 35 44 53 00 00    	push   0x5344
     24b:	e8 34 36 00 00       	call   3884 <printf>
    exit();
     250:	e8 ca 34 00 00       	call   371f <exit>
    }
    exit();
     255:	e8 c5 34 00 00       	call   371f <exit>
  }
  sleep(1);
     25a:	83 ec 0c             	sub    $0xc,%esp
     25d:	6a 01                	push   $0x1
     25f:	e8 4b 35 00 00       	call   37af <sleep>
  if(unlink("oidir") != 0){
     264:	c7 04 24 d3 3b 00 00 	movl   $0x3bd3,(%esp)
     26b:	e8 ff 34 00 00       	call   376f <unlink>
     270:	83 c4 10             	add    $0x10,%esp
     273:	85 c0                	test   %eax,%eax
     275:	75 1d                	jne    294 <openiputtest+0xd1>
    printf(stdout, "unlink failed\n");
    exit();
  }
  wait();
     277:	e8 ab 34 00 00       	call   3727 <wait>
  printf(stdout, "openiput test ok\n");
     27c:	83 ec 08             	sub    $0x8,%esp
     27f:	68 fc 3b 00 00       	push   $0x3bfc
     284:	ff 35 44 53 00 00    	push   0x5344
     28a:	e8 f5 35 00 00       	call   3884 <printf>
}
     28f:	83 c4 10             	add    $0x10,%esp
     292:	c9                   	leave  
     293:	c3                   	ret    
    printf(stdout, "unlink failed\n");
     294:	83 ec 08             	sub    $0x8,%esp
     297:	68 ed 3b 00 00       	push   $0x3bed
     29c:	ff 35 44 53 00 00    	push   0x5344
     2a2:	e8 dd 35 00 00       	call   3884 <printf>
    exit();
     2a7:	e8 73 34 00 00       	call   371f <exit>

000002ac <opentest>:

// simple file system tests

void
opentest(void)
{
     2ac:	55                   	push   %ebp
     2ad:	89 e5                	mov    %esp,%ebp
     2af:	83 ec 10             	sub    $0x10,%esp
  int fd;

  printf(stdout, "open test\n");
     2b2:	68 0e 3c 00 00       	push   $0x3c0e
     2b7:	ff 35 44 53 00 00    	push   0x5344
     2bd:	e8 c2 35 00 00       	call   3884 <printf>
  fd = open("echo", 0);
     2c2:	83 c4 08             	add    $0x8,%esp
     2c5:	6a 00                	push   $0x0
     2c7:	68 19 3c 00 00       	push   $0x3c19
     2cc:	e8 8e 34 00 00       	call   375f <open>
  if(fd < 0){
     2d1:	83 c4 10             	add    $0x10,%esp
     2d4:	85 c0                	test   %eax,%eax
     2d6:	78 37                	js     30f <opentest+0x63>
    printf(stdout, "open echo failed!\n");
    exit();
  }
  close(fd);
     2d8:	83 ec 0c             	sub    $0xc,%esp
     2db:	50                   	push   %eax
     2dc:	e8 66 34 00 00       	call   3747 <close>
  fd = open("doesnotexist", 0);
     2e1:	83 c4 08             	add    $0x8,%esp
     2e4:	6a 00                	push   $0x0
     2e6:	68 31 3c 00 00       	push   $0x3c31
     2eb:	e8 6f 34 00 00       	call   375f <open>
  if(fd >= 0){
     2f0:	83 c4 10             	add    $0x10,%esp
     2f3:	85 c0                	test   %eax,%eax
     2f5:	79 30                	jns    327 <opentest+0x7b>
    printf(stdout, "open doesnotexist succeeded!\n");
    exit();
  }
  printf(stdout, "open test ok\n");
     2f7:	83 ec 08             	sub    $0x8,%esp
     2fa:	68 5c 3c 00 00       	push   $0x3c5c
     2ff:	ff 35 44 53 00 00    	push   0x5344
     305:	e8 7a 35 00 00       	call   3884 <printf>
}
     30a:	83 c4 10             	add    $0x10,%esp
     30d:	c9                   	leave  
     30e:	c3                   	ret    
    printf(stdout, "open echo failed!\n");
     30f:	83 ec 08             	sub    $0x8,%esp
     312:	68 1e 3c 00 00       	push   $0x3c1e
     317:	ff 35 44 53 00 00    	push   0x5344
     31d:	e8 62 35 00 00       	call   3884 <printf>
    exit();
     322:	e8 f8 33 00 00       	call   371f <exit>
    printf(stdout, "open doesnotexist succeeded!\n");
     327:	83 ec 08             	sub    $0x8,%esp
     32a:	68 3e 3c 00 00       	push   $0x3c3e
     32f:	ff 35 44 53 00 00    	push   0x5344
     335:	e8 4a 35 00 00       	call   3884 <printf>
    exit();
     33a:	e8 e0 33 00 00       	call   371f <exit>

0000033f <writetest>:

void
writetest(void)
{
     33f:	55                   	push   %ebp
     340:	89 e5                	mov    %esp,%ebp
     342:	56                   	push   %esi
     343:	53                   	push   %ebx
  int fd;
  int i;

  printf(stdout, "small file test\n");
     344:	83 ec 08             	sub    $0x8,%esp
     347:	68 6a 3c 00 00       	push   $0x3c6a
     34c:	ff 35 44 53 00 00    	push   0x5344
     352:	e8 2d 35 00 00       	call   3884 <printf>
  fd = open("small", O_CREATE|O_RDWR);
     357:	83 c4 08             	add    $0x8,%esp
     35a:	68 02 02 00 00       	push   $0x202
     35f:	68 7b 3c 00 00       	push   $0x3c7b
     364:	e8 f6 33 00 00       	call   375f <open>
  if(fd >= 0){
     369:	83 c4 10             	add    $0x10,%esp
     36c:	85 c0                	test   %eax,%eax
     36e:	78 57                	js     3c7 <writetest+0x88>
     370:	89 c6                	mov    %eax,%esi
    printf(stdout, "creat small succeeded; ok\n");
     372:	83 ec 08             	sub    $0x8,%esp
     375:	68 81 3c 00 00       	push   $0x3c81
     37a:	ff 35 44 53 00 00    	push   0x5344
     380:	e8 ff 34 00 00       	call   3884 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     385:	83 c4 10             	add    $0x10,%esp
     388:	bb 00 00 00 00       	mov    $0x0,%ebx
     38d:	83 fb 63             	cmp    $0x63,%ebx
     390:	7f 7f                	jg     411 <writetest+0xd2>
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     392:	83 ec 04             	sub    $0x4,%esp
     395:	6a 0a                	push   $0xa
     397:	68 b8 3c 00 00       	push   $0x3cb8
     39c:	56                   	push   %esi
     39d:	e8 9d 33 00 00       	call   373f <write>
     3a2:	83 c4 10             	add    $0x10,%esp
     3a5:	83 f8 0a             	cmp    $0xa,%eax
     3a8:	75 35                	jne    3df <writetest+0xa0>
      printf(stdout, "error: write aa %d new file failed\n", i);
      exit();
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     3aa:	83 ec 04             	sub    $0x4,%esp
     3ad:	6a 0a                	push   $0xa
     3af:	68 c3 3c 00 00       	push   $0x3cc3
     3b4:	56                   	push   %esi
     3b5:	e8 85 33 00 00       	call   373f <write>
     3ba:	83 c4 10             	add    $0x10,%esp
     3bd:	83 f8 0a             	cmp    $0xa,%eax
     3c0:	75 36                	jne    3f8 <writetest+0xb9>
  for(i = 0; i < 100; i++){
     3c2:	83 c3 01             	add    $0x1,%ebx
     3c5:	eb c6                	jmp    38d <writetest+0x4e>
    printf(stdout, "error: creat small failed!\n");
     3c7:	83 ec 08             	sub    $0x8,%esp
     3ca:	68 9c 3c 00 00       	push   $0x3c9c
     3cf:	ff 35 44 53 00 00    	push   0x5344
     3d5:	e8 aa 34 00 00       	call   3884 <printf>
    exit();
     3da:	e8 40 33 00 00       	call   371f <exit>
      printf(stdout, "error: write aa %d new file failed\n", i);
     3df:	83 ec 04             	sub    $0x4,%esp
     3e2:	53                   	push   %ebx
     3e3:	68 7c 4b 00 00       	push   $0x4b7c
     3e8:	ff 35 44 53 00 00    	push   0x5344
     3ee:	e8 91 34 00 00       	call   3884 <printf>
      exit();
     3f3:	e8 27 33 00 00       	call   371f <exit>
      printf(stdout, "error: write bb %d new file failed\n", i);
     3f8:	83 ec 04             	sub    $0x4,%esp
     3fb:	53                   	push   %ebx
     3fc:	68 a0 4b 00 00       	push   $0x4ba0
     401:	ff 35 44 53 00 00    	push   0x5344
     407:	e8 78 34 00 00       	call   3884 <printf>
      exit();
     40c:	e8 0e 33 00 00       	call   371f <exit>
    }
  }
  printf(stdout, "writes ok\n");
     411:	83 ec 08             	sub    $0x8,%esp
     414:	68 ce 3c 00 00       	push   $0x3cce
     419:	ff 35 44 53 00 00    	push   0x5344
     41f:	e8 60 34 00 00       	call   3884 <printf>
  close(fd);
     424:	89 34 24             	mov    %esi,(%esp)
     427:	e8 1b 33 00 00       	call   3747 <close>
  fd = open("small", O_RDONLY);
     42c:	83 c4 08             	add    $0x8,%esp
     42f:	6a 00                	push   $0x0
     431:	68 7b 3c 00 00       	push   $0x3c7b
     436:	e8 24 33 00 00       	call   375f <open>
     43b:	89 c3                	mov    %eax,%ebx
  if(fd >= 0){
     43d:	83 c4 10             	add    $0x10,%esp
     440:	85 c0                	test   %eax,%eax
     442:	78 7b                	js     4bf <writetest+0x180>
    printf(stdout, "open small succeeded ok\n");
     444:	83 ec 08             	sub    $0x8,%esp
     447:	68 d9 3c 00 00       	push   $0x3cd9
     44c:	ff 35 44 53 00 00    	push   0x5344
     452:	e8 2d 34 00 00       	call   3884 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     457:	83 c4 0c             	add    $0xc,%esp
     45a:	68 d0 07 00 00       	push   $0x7d0
     45f:	68 80 7a 00 00       	push   $0x7a80
     464:	53                   	push   %ebx
     465:	e8 cd 32 00 00       	call   3737 <read>
  if(i == 2000){
     46a:	83 c4 10             	add    $0x10,%esp
     46d:	3d d0 07 00 00       	cmp    $0x7d0,%eax
     472:	75 63                	jne    4d7 <writetest+0x198>
    printf(stdout, "read succeeded ok\n");
     474:	83 ec 08             	sub    $0x8,%esp
     477:	68 0d 3d 00 00       	push   $0x3d0d
     47c:	ff 35 44 53 00 00    	push   0x5344
     482:	e8 fd 33 00 00       	call   3884 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     487:	89 1c 24             	mov    %ebx,(%esp)
     48a:	e8 b8 32 00 00       	call   3747 <close>

  if(unlink("small") < 0){
     48f:	c7 04 24 7b 3c 00 00 	movl   $0x3c7b,(%esp)
     496:	e8 d4 32 00 00       	call   376f <unlink>
     49b:	83 c4 10             	add    $0x10,%esp
     49e:	85 c0                	test   %eax,%eax
     4a0:	78 4d                	js     4ef <writetest+0x1b0>
    printf(stdout, "unlink small failed\n");
    exit();
  }
  printf(stdout, "small file test ok\n");
     4a2:	83 ec 08             	sub    $0x8,%esp
     4a5:	68 35 3d 00 00       	push   $0x3d35
     4aa:	ff 35 44 53 00 00    	push   0x5344
     4b0:	e8 cf 33 00 00       	call   3884 <printf>
}
     4b5:	83 c4 10             	add    $0x10,%esp
     4b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
     4bb:	5b                   	pop    %ebx
     4bc:	5e                   	pop    %esi
     4bd:	5d                   	pop    %ebp
     4be:	c3                   	ret    
    printf(stdout, "error: open small failed!\n");
     4bf:	83 ec 08             	sub    $0x8,%esp
     4c2:	68 f2 3c 00 00       	push   $0x3cf2
     4c7:	ff 35 44 53 00 00    	push   0x5344
     4cd:	e8 b2 33 00 00       	call   3884 <printf>
    exit();
     4d2:	e8 48 32 00 00       	call   371f <exit>
    printf(stdout, "read failed\n");
     4d7:	83 ec 08             	sub    $0x8,%esp
     4da:	68 39 40 00 00       	push   $0x4039
     4df:	ff 35 44 53 00 00    	push   0x5344
     4e5:	e8 9a 33 00 00       	call   3884 <printf>
    exit();
     4ea:	e8 30 32 00 00       	call   371f <exit>
    printf(stdout, "unlink small failed\n");
     4ef:	83 ec 08             	sub    $0x8,%esp
     4f2:	68 20 3d 00 00       	push   $0x3d20
     4f7:	ff 35 44 53 00 00    	push   0x5344
     4fd:	e8 82 33 00 00       	call   3884 <printf>
    exit();
     502:	e8 18 32 00 00       	call   371f <exit>

00000507 <writetest1>:

void
writetest1(void)
{
     507:	55                   	push   %ebp
     508:	89 e5                	mov    %esp,%ebp
     50a:	56                   	push   %esi
     50b:	53                   	push   %ebx
  int i, fd, n;

  printf(stdout, "big files test\n");
     50c:	83 ec 08             	sub    $0x8,%esp
     50f:	68 49 3d 00 00       	push   $0x3d49
     514:	ff 35 44 53 00 00    	push   0x5344
     51a:	e8 65 33 00 00       	call   3884 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     51f:	83 c4 08             	add    $0x8,%esp
     522:	68 02 02 00 00       	push   $0x202
     527:	68 c3 3d 00 00       	push   $0x3dc3
     52c:	e8 2e 32 00 00       	call   375f <open>
  if(fd < 0){
     531:	83 c4 10             	add    $0x10,%esp
     534:	85 c0                	test   %eax,%eax
     536:	78 37                	js     56f <writetest1+0x68>
     538:	89 c6                	mov    %eax,%esi
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     53a:	bb 00 00 00 00       	mov    $0x0,%ebx
     53f:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
     545:	77 59                	ja     5a0 <writetest1+0x99>
    ((int*)buf)[0] = i;
     547:	89 1d 80 7a 00 00    	mov    %ebx,0x7a80
    if(write(fd, buf, 512) != 512){
     54d:	83 ec 04             	sub    $0x4,%esp
     550:	68 00 02 00 00       	push   $0x200
     555:	68 80 7a 00 00       	push   $0x7a80
     55a:	56                   	push   %esi
     55b:	e8 df 31 00 00       	call   373f <write>
     560:	83 c4 10             	add    $0x10,%esp
     563:	3d 00 02 00 00       	cmp    $0x200,%eax
     568:	75 1d                	jne    587 <writetest1+0x80>
  for(i = 0; i < MAXFILE; i++){
     56a:	83 c3 01             	add    $0x1,%ebx
     56d:	eb d0                	jmp    53f <writetest1+0x38>
    printf(stdout, "error: creat big failed!\n");
     56f:	83 ec 08             	sub    $0x8,%esp
     572:	68 59 3d 00 00       	push   $0x3d59
     577:	ff 35 44 53 00 00    	push   0x5344
     57d:	e8 02 33 00 00       	call   3884 <printf>
    exit();
     582:	e8 98 31 00 00       	call   371f <exit>
      printf(stdout, "error: write big file failed\n", i);
     587:	83 ec 04             	sub    $0x4,%esp
     58a:	53                   	push   %ebx
     58b:	68 73 3d 00 00       	push   $0x3d73
     590:	ff 35 44 53 00 00    	push   0x5344
     596:	e8 e9 32 00 00       	call   3884 <printf>
      exit();
     59b:	e8 7f 31 00 00       	call   371f <exit>
    }
  }

  close(fd);
     5a0:	83 ec 0c             	sub    $0xc,%esp
     5a3:	56                   	push   %esi
     5a4:	e8 9e 31 00 00       	call   3747 <close>

  fd = open("big", O_RDONLY);
     5a9:	83 c4 08             	add    $0x8,%esp
     5ac:	6a 00                	push   $0x0
     5ae:	68 c3 3d 00 00       	push   $0x3dc3
     5b3:	e8 a7 31 00 00       	call   375f <open>
     5b8:	89 c6                	mov    %eax,%esi
  if(fd < 0){
     5ba:	83 c4 10             	add    $0x10,%esp
     5bd:	85 c0                	test   %eax,%eax
     5bf:	78 3c                	js     5fd <writetest1+0xf6>
    printf(stdout, "error: open big failed!\n");
    exit();
  }

  n = 0;
     5c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(;;){
    i = read(fd, buf, 512);
     5c6:	83 ec 04             	sub    $0x4,%esp
     5c9:	68 00 02 00 00       	push   $0x200
     5ce:	68 80 7a 00 00       	push   $0x7a80
     5d3:	56                   	push   %esi
     5d4:	e8 5e 31 00 00       	call   3737 <read>
    if(i == 0){
     5d9:	83 c4 10             	add    $0x10,%esp
     5dc:	85 c0                	test   %eax,%eax
     5de:	74 35                	je     615 <writetest1+0x10e>
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
     5e0:	3d 00 02 00 00       	cmp    $0x200,%eax
     5e5:	0f 85 84 00 00 00    	jne    66f <writetest1+0x168>
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
     5eb:	a1 80 7a 00 00       	mov    0x7a80,%eax
     5f0:	39 d8                	cmp    %ebx,%eax
     5f2:	0f 85 90 00 00 00    	jne    688 <writetest1+0x181>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
     5f8:	83 c3 01             	add    $0x1,%ebx
    i = read(fd, buf, 512);
     5fb:	eb c9                	jmp    5c6 <writetest1+0xbf>
    printf(stdout, "error: open big failed!\n");
     5fd:	83 ec 08             	sub    $0x8,%esp
     600:	68 91 3d 00 00       	push   $0x3d91
     605:	ff 35 44 53 00 00    	push   0x5344
     60b:	e8 74 32 00 00       	call   3884 <printf>
    exit();
     610:	e8 0a 31 00 00       	call   371f <exit>
      if(n == MAXFILE - 1){
     615:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
     61b:	74 39                	je     656 <writetest1+0x14f>
  }
  close(fd);
     61d:	83 ec 0c             	sub    $0xc,%esp
     620:	56                   	push   %esi
     621:	e8 21 31 00 00       	call   3747 <close>
  if(unlink("big") < 0){
     626:	c7 04 24 c3 3d 00 00 	movl   $0x3dc3,(%esp)
     62d:	e8 3d 31 00 00       	call   376f <unlink>
     632:	83 c4 10             	add    $0x10,%esp
     635:	85 c0                	test   %eax,%eax
     637:	78 66                	js     69f <writetest1+0x198>
    printf(stdout, "unlink big failed\n");
    exit();
  }
  printf(stdout, "big files ok\n");
     639:	83 ec 08             	sub    $0x8,%esp
     63c:	68 ea 3d 00 00       	push   $0x3dea
     641:	ff 35 44 53 00 00    	push   0x5344
     647:	e8 38 32 00 00       	call   3884 <printf>
}
     64c:	83 c4 10             	add    $0x10,%esp
     64f:	8d 65 f8             	lea    -0x8(%ebp),%esp
     652:	5b                   	pop    %ebx
     653:	5e                   	pop    %esi
     654:	5d                   	pop    %ebp
     655:	c3                   	ret    
        printf(stdout, "read only %d blocks from big", n);
     656:	83 ec 04             	sub    $0x4,%esp
     659:	53                   	push   %ebx
     65a:	68 aa 3d 00 00       	push   $0x3daa
     65f:	ff 35 44 53 00 00    	push   0x5344
     665:	e8 1a 32 00 00       	call   3884 <printf>
        exit();
     66a:	e8 b0 30 00 00       	call   371f <exit>
      printf(stdout, "read failed %d\n", i);
     66f:	83 ec 04             	sub    $0x4,%esp
     672:	50                   	push   %eax
     673:	68 c7 3d 00 00       	push   $0x3dc7
     678:	ff 35 44 53 00 00    	push   0x5344
     67e:	e8 01 32 00 00       	call   3884 <printf>
      exit();
     683:	e8 97 30 00 00       	call   371f <exit>
      printf(stdout, "read content of block %d is %d\n",
     688:	50                   	push   %eax
     689:	53                   	push   %ebx
     68a:	68 c4 4b 00 00       	push   $0x4bc4
     68f:	ff 35 44 53 00 00    	push   0x5344
     695:	e8 ea 31 00 00       	call   3884 <printf>
      exit();
     69a:	e8 80 30 00 00       	call   371f <exit>
    printf(stdout, "unlink big failed\n");
     69f:	83 ec 08             	sub    $0x8,%esp
     6a2:	68 d7 3d 00 00       	push   $0x3dd7
     6a7:	ff 35 44 53 00 00    	push   0x5344
     6ad:	e8 d2 31 00 00       	call   3884 <printf>
    exit();
     6b2:	e8 68 30 00 00       	call   371f <exit>

000006b7 <createtest>:

void
createtest(void)
{
     6b7:	55                   	push   %ebp
     6b8:	89 e5                	mov    %esp,%ebp
     6ba:	53                   	push   %ebx
     6bb:	83 ec 0c             	sub    $0xc,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     6be:	68 e4 4b 00 00       	push   $0x4be4
     6c3:	ff 35 44 53 00 00    	push   0x5344
     6c9:	e8 b6 31 00 00       	call   3884 <printf>

  name[0] = 'a';
     6ce:	c6 05 70 7a 00 00 61 	movb   $0x61,0x7a70
  name[2] = '\0';
     6d5:	c6 05 72 7a 00 00 00 	movb   $0x0,0x7a72
  for(i = 0; i < 52; i++){
     6dc:	83 c4 10             	add    $0x10,%esp
     6df:	bb 00 00 00 00       	mov    $0x0,%ebx
     6e4:	eb 28                	jmp    70e <createtest+0x57>
    name[1] = '0' + i;
     6e6:	8d 43 30             	lea    0x30(%ebx),%eax
     6e9:	a2 71 7a 00 00       	mov    %al,0x7a71
    fd = open(name, O_CREATE|O_RDWR);
     6ee:	83 ec 08             	sub    $0x8,%esp
     6f1:	68 02 02 00 00       	push   $0x202
     6f6:	68 70 7a 00 00       	push   $0x7a70
     6fb:	e8 5f 30 00 00       	call   375f <open>
    close(fd);
     700:	89 04 24             	mov    %eax,(%esp)
     703:	e8 3f 30 00 00       	call   3747 <close>
  for(i = 0; i < 52; i++){
     708:	83 c3 01             	add    $0x1,%ebx
     70b:	83 c4 10             	add    $0x10,%esp
     70e:	83 fb 33             	cmp    $0x33,%ebx
     711:	7e d3                	jle    6e6 <createtest+0x2f>
  }
  name[0] = 'a';
     713:	c6 05 70 7a 00 00 61 	movb   $0x61,0x7a70
  name[2] = '\0';
     71a:	c6 05 72 7a 00 00 00 	movb   $0x0,0x7a72
  for(i = 0; i < 52; i++){
     721:	bb 00 00 00 00       	mov    $0x0,%ebx
     726:	eb 1b                	jmp    743 <createtest+0x8c>
    name[1] = '0' + i;
     728:	8d 43 30             	lea    0x30(%ebx),%eax
     72b:	a2 71 7a 00 00       	mov    %al,0x7a71
    unlink(name);
     730:	83 ec 0c             	sub    $0xc,%esp
     733:	68 70 7a 00 00       	push   $0x7a70
     738:	e8 32 30 00 00       	call   376f <unlink>
  for(i = 0; i < 52; i++){
     73d:	83 c3 01             	add    $0x1,%ebx
     740:	83 c4 10             	add    $0x10,%esp
     743:	83 fb 33             	cmp    $0x33,%ebx
     746:	7e e0                	jle    728 <createtest+0x71>
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     748:	83 ec 08             	sub    $0x8,%esp
     74b:	68 0c 4c 00 00       	push   $0x4c0c
     750:	ff 35 44 53 00 00    	push   0x5344
     756:	e8 29 31 00 00       	call   3884 <printf>
}
     75b:	83 c4 10             	add    $0x10,%esp
     75e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     761:	c9                   	leave  
     762:	c3                   	ret    

00000763 <dirtest>:

void dirtest(void)
{
     763:	55                   	push   %ebp
     764:	89 e5                	mov    %esp,%ebp
     766:	83 ec 10             	sub    $0x10,%esp
  printf(stdout, "mkdir test\n");
     769:	68 f8 3d 00 00       	push   $0x3df8
     76e:	ff 35 44 53 00 00    	push   0x5344
     774:	e8 0b 31 00 00       	call   3884 <printf>

  if(mkdir("dir0") < 0){
     779:	c7 04 24 04 3e 00 00 	movl   $0x3e04,(%esp)
     780:	e8 02 30 00 00       	call   3787 <mkdir>
     785:	83 c4 10             	add    $0x10,%esp
     788:	85 c0                	test   %eax,%eax
     78a:	78 54                	js     7e0 <dirtest+0x7d>
    printf(stdout, "mkdir failed\n");
    exit();
  }

  if(chdir("dir0") < 0){
     78c:	83 ec 0c             	sub    $0xc,%esp
     78f:	68 04 3e 00 00       	push   $0x3e04
     794:	e8 f6 2f 00 00       	call   378f <chdir>
     799:	83 c4 10             	add    $0x10,%esp
     79c:	85 c0                	test   %eax,%eax
     79e:	78 58                	js     7f8 <dirtest+0x95>
    printf(stdout, "chdir dir0 failed\n");
    exit();
  }

  if(chdir("..") < 0){
     7a0:	83 ec 0c             	sub    $0xc,%esp
     7a3:	68 a9 43 00 00       	push   $0x43a9
     7a8:	e8 e2 2f 00 00       	call   378f <chdir>
     7ad:	83 c4 10             	add    $0x10,%esp
     7b0:	85 c0                	test   %eax,%eax
     7b2:	78 5c                	js     810 <dirtest+0xad>
    printf(stdout, "chdir .. failed\n");
    exit();
  }

  if(unlink("dir0") < 0){
     7b4:	83 ec 0c             	sub    $0xc,%esp
     7b7:	68 04 3e 00 00       	push   $0x3e04
     7bc:	e8 ae 2f 00 00       	call   376f <unlink>
     7c1:	83 c4 10             	add    $0x10,%esp
     7c4:	85 c0                	test   %eax,%eax
     7c6:	78 60                	js     828 <dirtest+0xc5>
    printf(stdout, "unlink dir0 failed\n");
    exit();
  }
  printf(stdout, "mkdir test ok\n");
     7c8:	83 ec 08             	sub    $0x8,%esp
     7cb:	68 41 3e 00 00       	push   $0x3e41
     7d0:	ff 35 44 53 00 00    	push   0x5344
     7d6:	e8 a9 30 00 00       	call   3884 <printf>
}
     7db:	83 c4 10             	add    $0x10,%esp
     7de:	c9                   	leave  
     7df:	c3                   	ret    
    printf(stdout, "mkdir failed\n");
     7e0:	83 ec 08             	sub    $0x8,%esp
     7e3:	68 34 3b 00 00       	push   $0x3b34
     7e8:	ff 35 44 53 00 00    	push   0x5344
     7ee:	e8 91 30 00 00       	call   3884 <printf>
    exit();
     7f3:	e8 27 2f 00 00       	call   371f <exit>
    printf(stdout, "chdir dir0 failed\n");
     7f8:	83 ec 08             	sub    $0x8,%esp
     7fb:	68 09 3e 00 00       	push   $0x3e09
     800:	ff 35 44 53 00 00    	push   0x5344
     806:	e8 79 30 00 00       	call   3884 <printf>
    exit();
     80b:	e8 0f 2f 00 00       	call   371f <exit>
    printf(stdout, "chdir .. failed\n");
     810:	83 ec 08             	sub    $0x8,%esp
     813:	68 1c 3e 00 00       	push   $0x3e1c
     818:	ff 35 44 53 00 00    	push   0x5344
     81e:	e8 61 30 00 00       	call   3884 <printf>
    exit();
     823:	e8 f7 2e 00 00       	call   371f <exit>
    printf(stdout, "unlink dir0 failed\n");
     828:	83 ec 08             	sub    $0x8,%esp
     82b:	68 2d 3e 00 00       	push   $0x3e2d
     830:	ff 35 44 53 00 00    	push   0x5344
     836:	e8 49 30 00 00       	call   3884 <printf>
    exit();
     83b:	e8 df 2e 00 00       	call   371f <exit>

00000840 <exectest>:

void
exectest(void)
{
     840:	55                   	push   %ebp
     841:	89 e5                	mov    %esp,%ebp
     843:	83 ec 10             	sub    $0x10,%esp
  printf(stdout, "exec test\n");
     846:	68 50 3e 00 00       	push   $0x3e50
     84b:	ff 35 44 53 00 00    	push   0x5344
     851:	e8 2e 30 00 00       	call   3884 <printf>
  if(exec("echo", echoargv) < 0){
     856:	83 c4 08             	add    $0x8,%esp
     859:	68 48 53 00 00       	push   $0x5348
     85e:	68 19 3c 00 00       	push   $0x3c19
     863:	e8 ef 2e 00 00       	call   3757 <exec>
     868:	83 c4 10             	add    $0x10,%esp
     86b:	85 c0                	test   %eax,%eax
     86d:	78 02                	js     871 <exectest+0x31>
    printf(stdout, "exec echo failed\n");
    exit();
  }
}
     86f:	c9                   	leave  
     870:	c3                   	ret    
    printf(stdout, "exec echo failed\n");
     871:	83 ec 08             	sub    $0x8,%esp
     874:	68 5b 3e 00 00       	push   $0x3e5b
     879:	ff 35 44 53 00 00    	push   0x5344
     87f:	e8 00 30 00 00       	call   3884 <printf>
    exit();
     884:	e8 96 2e 00 00       	call   371f <exit>

00000889 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     889:	55                   	push   %ebp
     88a:	89 e5                	mov    %esp,%ebp
     88c:	57                   	push   %edi
     88d:	56                   	push   %esi
     88e:	53                   	push   %ebx
     88f:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     892:	8d 45 e0             	lea    -0x20(%ebp),%eax
     895:	50                   	push   %eax
     896:	e8 94 2e 00 00       	call   372f <pipe>
     89b:	83 c4 10             	add    $0x10,%esp
     89e:	85 c0                	test   %eax,%eax
     8a0:	75 74                	jne    916 <pipe1+0x8d>
     8a2:	89 c6                	mov    %eax,%esi
    printf(1, "pipe() failed\n");
    exit();
  }
  pid = fork();
     8a4:	e8 6e 2e 00 00       	call   3717 <fork>
     8a9:	89 c7                	mov    %eax,%edi
  seq = 0;
  if(pid == 0){
     8ab:	85 c0                	test   %eax,%eax
     8ad:	74 7b                	je     92a <pipe1+0xa1>
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
  } else if(pid > 0){
     8af:	0f 8e 60 01 00 00    	jle    a15 <pipe1+0x18c>
    close(fds[1]);
     8b5:	83 ec 0c             	sub    $0xc,%esp
     8b8:	ff 75 e4             	push   -0x1c(%ebp)
     8bb:	e8 87 2e 00 00       	call   3747 <close>
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     8c0:	83 c4 10             	add    $0x10,%esp
    total = 0;
     8c3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  seq = 0;
     8c6:	89 f3                	mov    %esi,%ebx
    cc = 1;
     8c8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     8cf:	83 ec 04             	sub    $0x4,%esp
     8d2:	ff 75 d4             	push   -0x2c(%ebp)
     8d5:	68 80 7a 00 00       	push   $0x7a80
     8da:	ff 75 e0             	push   -0x20(%ebp)
     8dd:	e8 55 2e 00 00       	call   3737 <read>
     8e2:	89 c7                	mov    %eax,%edi
     8e4:	83 c4 10             	add    $0x10,%esp
     8e7:	85 c0                	test   %eax,%eax
     8e9:	0f 8e e2 00 00 00    	jle    9d1 <pipe1+0x148>
      for(i = 0; i < n; i++){
     8ef:	89 f0                	mov    %esi,%eax
     8f1:	89 d9                	mov    %ebx,%ecx
     8f3:	39 f8                	cmp    %edi,%eax
     8f5:	0f 8d b4 00 00 00    	jge    9af <pipe1+0x126>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     8fb:	0f be 98 80 7a 00 00 	movsbl 0x7a80(%eax),%ebx
     902:	8d 51 01             	lea    0x1(%ecx),%edx
     905:	31 cb                	xor    %ecx,%ebx
     907:	84 db                	test   %bl,%bl
     909:	0f 85 86 00 00 00    	jne    995 <pipe1+0x10c>
      for(i = 0; i < n; i++){
     90f:	83 c0 01             	add    $0x1,%eax
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     912:	89 d1                	mov    %edx,%ecx
     914:	eb dd                	jmp    8f3 <pipe1+0x6a>
    printf(1, "pipe() failed\n");
     916:	83 ec 08             	sub    $0x8,%esp
     919:	68 6d 3e 00 00       	push   $0x3e6d
     91e:	6a 01                	push   $0x1
     920:	e8 5f 2f 00 00       	call   3884 <printf>
    exit();
     925:	e8 f5 2d 00 00       	call   371f <exit>
    close(fds[0]);
     92a:	83 ec 0c             	sub    $0xc,%esp
     92d:	ff 75 e0             	push   -0x20(%ebp)
     930:	e8 12 2e 00 00       	call   3747 <close>
    for(n = 0; n < 5; n++){
     935:	83 c4 10             	add    $0x10,%esp
     938:	89 fe                	mov    %edi,%esi
  seq = 0;
     93a:	89 fb                	mov    %edi,%ebx
    for(n = 0; n < 5; n++){
     93c:	eb 35                	jmp    973 <pipe1+0xea>
        buf[i] = seq++;
     93e:	88 98 80 7a 00 00    	mov    %bl,0x7a80(%eax)
      for(i = 0; i < 1033; i++)
     944:	83 c0 01             	add    $0x1,%eax
        buf[i] = seq++;
     947:	8d 5b 01             	lea    0x1(%ebx),%ebx
      for(i = 0; i < 1033; i++)
     94a:	3d 08 04 00 00       	cmp    $0x408,%eax
     94f:	7e ed                	jle    93e <pipe1+0xb5>
      if(write(fds[1], buf, 1033) != 1033){
     951:	83 ec 04             	sub    $0x4,%esp
     954:	68 09 04 00 00       	push   $0x409
     959:	68 80 7a 00 00       	push   $0x7a80
     95e:	ff 75 e4             	push   -0x1c(%ebp)
     961:	e8 d9 2d 00 00       	call   373f <write>
     966:	83 c4 10             	add    $0x10,%esp
     969:	3d 09 04 00 00       	cmp    $0x409,%eax
     96e:	75 0c                	jne    97c <pipe1+0xf3>
    for(n = 0; n < 5; n++){
     970:	83 c6 01             	add    $0x1,%esi
     973:	83 fe 04             	cmp    $0x4,%esi
     976:	7f 18                	jg     990 <pipe1+0x107>
      for(i = 0; i < 1033; i++)
     978:	89 f8                	mov    %edi,%eax
     97a:	eb ce                	jmp    94a <pipe1+0xc1>
        printf(1, "pipe1 oops 1\n");
     97c:	83 ec 08             	sub    $0x8,%esp
     97f:	68 7c 3e 00 00       	push   $0x3e7c
     984:	6a 01                	push   $0x1
     986:	e8 f9 2e 00 00       	call   3884 <printf>
        exit();
     98b:	e8 8f 2d 00 00       	call   371f <exit>
    exit();
     990:	e8 8a 2d 00 00       	call   371f <exit>
          printf(1, "pipe1 oops 2\n");
     995:	83 ec 08             	sub    $0x8,%esp
     998:	68 8a 3e 00 00       	push   $0x3e8a
     99d:	6a 01                	push   $0x1
     99f:	e8 e0 2e 00 00       	call   3884 <printf>
          return;
     9a4:	83 c4 10             	add    $0x10,%esp
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
}
     9a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
     9aa:	5b                   	pop    %ebx
     9ab:	5e                   	pop    %esi
     9ac:	5f                   	pop    %edi
     9ad:	5d                   	pop    %ebp
     9ae:	c3                   	ret    
      total += n;
     9af:	89 cb                	mov    %ecx,%ebx
     9b1:	01 7d d0             	add    %edi,-0x30(%ebp)
      cc = cc * 2;
     9b4:	d1 65 d4             	shll   -0x2c(%ebp)
     9b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
      if(cc > sizeof(buf))
     9ba:	3d 00 20 00 00       	cmp    $0x2000,%eax
     9bf:	0f 86 0a ff ff ff    	jbe    8cf <pipe1+0x46>
        cc = sizeof(buf);
     9c5:	c7 45 d4 00 20 00 00 	movl   $0x2000,-0x2c(%ebp)
     9cc:	e9 fe fe ff ff       	jmp    8cf <pipe1+0x46>
    if(total != 5 * 1033){
     9d1:	81 7d d0 2d 14 00 00 	cmpl   $0x142d,-0x30(%ebp)
     9d8:	75 24                	jne    9fe <pipe1+0x175>
    close(fds[0]);
     9da:	83 ec 0c             	sub    $0xc,%esp
     9dd:	ff 75 e0             	push   -0x20(%ebp)
     9e0:	e8 62 2d 00 00       	call   3747 <close>
    wait();
     9e5:	e8 3d 2d 00 00       	call   3727 <wait>
  printf(1, "pipe1 ok\n");
     9ea:	83 c4 08             	add    $0x8,%esp
     9ed:	68 af 3e 00 00       	push   $0x3eaf
     9f2:	6a 01                	push   $0x1
     9f4:	e8 8b 2e 00 00       	call   3884 <printf>
     9f9:	83 c4 10             	add    $0x10,%esp
     9fc:	eb a9                	jmp    9a7 <pipe1+0x11e>
      printf(1, "pipe1 oops 3 total %d\n", total);
     9fe:	83 ec 04             	sub    $0x4,%esp
     a01:	ff 75 d0             	push   -0x30(%ebp)
     a04:	68 98 3e 00 00       	push   $0x3e98
     a09:	6a 01                	push   $0x1
     a0b:	e8 74 2e 00 00       	call   3884 <printf>
      exit();
     a10:	e8 0a 2d 00 00       	call   371f <exit>
    printf(1, "fork() failed\n");
     a15:	83 ec 08             	sub    $0x8,%esp
     a18:	68 b9 3e 00 00       	push   $0x3eb9
     a1d:	6a 01                	push   $0x1
     a1f:	e8 60 2e 00 00       	call   3884 <printf>
    exit();
     a24:	e8 f6 2c 00 00       	call   371f <exit>

00000a29 <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     a29:	55                   	push   %ebp
     a2a:	89 e5                	mov    %esp,%ebp
     a2c:	57                   	push   %edi
     a2d:	56                   	push   %esi
     a2e:	53                   	push   %ebx
     a2f:	83 ec 24             	sub    $0x24,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     a32:	68 c8 3e 00 00       	push   $0x3ec8
     a37:	6a 01                	push   $0x1
     a39:	e8 46 2e 00 00       	call   3884 <printf>
  pid1 = fork();
     a3e:	e8 d4 2c 00 00       	call   3717 <fork>
  if(pid1 == 0)
     a43:	83 c4 10             	add    $0x10,%esp
     a46:	85 c0                	test   %eax,%eax
     a48:	75 02                	jne    a4c <preempt+0x23>
    for(;;)
     a4a:	eb fe                	jmp    a4a <preempt+0x21>
     a4c:	89 c3                	mov    %eax,%ebx
      ;

  pid2 = fork();
     a4e:	e8 c4 2c 00 00       	call   3717 <fork>
     a53:	89 c6                	mov    %eax,%esi
  if(pid2 == 0)
     a55:	85 c0                	test   %eax,%eax
     a57:	75 02                	jne    a5b <preempt+0x32>
    for(;;)
     a59:	eb fe                	jmp    a59 <preempt+0x30>
      ;

  pipe(pfds);
     a5b:	83 ec 0c             	sub    $0xc,%esp
     a5e:	8d 45 e0             	lea    -0x20(%ebp),%eax
     a61:	50                   	push   %eax
     a62:	e8 c8 2c 00 00       	call   372f <pipe>
  pid3 = fork();
     a67:	e8 ab 2c 00 00       	call   3717 <fork>
     a6c:	89 c7                	mov    %eax,%edi
  if(pid3 == 0){
     a6e:	83 c4 10             	add    $0x10,%esp
     a71:	85 c0                	test   %eax,%eax
     a73:	75 49                	jne    abe <preempt+0x95>
    close(pfds[0]);
     a75:	83 ec 0c             	sub    $0xc,%esp
     a78:	ff 75 e0             	push   -0x20(%ebp)
     a7b:	e8 c7 2c 00 00       	call   3747 <close>
    if(write(pfds[1], "x", 1) != 1)
     a80:	83 c4 0c             	add    $0xc,%esp
     a83:	6a 01                	push   $0x1
     a85:	68 8d 44 00 00       	push   $0x448d
     a8a:	ff 75 e4             	push   -0x1c(%ebp)
     a8d:	e8 ad 2c 00 00       	call   373f <write>
     a92:	83 c4 10             	add    $0x10,%esp
     a95:	83 f8 01             	cmp    $0x1,%eax
     a98:	75 10                	jne    aaa <preempt+0x81>
      printf(1, "preempt write error");
    close(pfds[1]);
     a9a:	83 ec 0c             	sub    $0xc,%esp
     a9d:	ff 75 e4             	push   -0x1c(%ebp)
     aa0:	e8 a2 2c 00 00       	call   3747 <close>
     aa5:	83 c4 10             	add    $0x10,%esp
    for(;;)
     aa8:	eb fe                	jmp    aa8 <preempt+0x7f>
      printf(1, "preempt write error");
     aaa:	83 ec 08             	sub    $0x8,%esp
     aad:	68 d2 3e 00 00       	push   $0x3ed2
     ab2:	6a 01                	push   $0x1
     ab4:	e8 cb 2d 00 00       	call   3884 <printf>
     ab9:	83 c4 10             	add    $0x10,%esp
     abc:	eb dc                	jmp    a9a <preempt+0x71>
      ;
  }

  close(pfds[1]);
     abe:	83 ec 0c             	sub    $0xc,%esp
     ac1:	ff 75 e4             	push   -0x1c(%ebp)
     ac4:	e8 7e 2c 00 00       	call   3747 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     ac9:	83 c4 0c             	add    $0xc,%esp
     acc:	68 00 20 00 00       	push   $0x2000
     ad1:	68 80 7a 00 00       	push   $0x7a80
     ad6:	ff 75 e0             	push   -0x20(%ebp)
     ad9:	e8 59 2c 00 00       	call   3737 <read>
     ade:	83 c4 10             	add    $0x10,%esp
     ae1:	83 f8 01             	cmp    $0x1,%eax
     ae4:	74 1a                	je     b00 <preempt+0xd7>
    printf(1, "preempt read error");
     ae6:	83 ec 08             	sub    $0x8,%esp
     ae9:	68 e6 3e 00 00       	push   $0x3ee6
     aee:	6a 01                	push   $0x1
     af0:	e8 8f 2d 00 00       	call   3884 <printf>
    return;
     af5:	83 c4 10             	add    $0x10,%esp
  printf(1, "wait... ");
  wait();
  wait();
  wait();
  printf(1, "preempt ok\n");
}
     af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
     afb:	5b                   	pop    %ebx
     afc:	5e                   	pop    %esi
     afd:	5f                   	pop    %edi
     afe:	5d                   	pop    %ebp
     aff:	c3                   	ret    
  close(pfds[0]);
     b00:	83 ec 0c             	sub    $0xc,%esp
     b03:	ff 75 e0             	push   -0x20(%ebp)
     b06:	e8 3c 2c 00 00       	call   3747 <close>
  printf(1, "kill... ");
     b0b:	83 c4 08             	add    $0x8,%esp
     b0e:	68 f9 3e 00 00       	push   $0x3ef9
     b13:	6a 01                	push   $0x1
     b15:	e8 6a 2d 00 00       	call   3884 <printf>
  kill(pid1);
     b1a:	89 1c 24             	mov    %ebx,(%esp)
     b1d:	e8 2d 2c 00 00       	call   374f <kill>
  kill(pid2);
     b22:	89 34 24             	mov    %esi,(%esp)
     b25:	e8 25 2c 00 00       	call   374f <kill>
  kill(pid3);
     b2a:	89 3c 24             	mov    %edi,(%esp)
     b2d:	e8 1d 2c 00 00       	call   374f <kill>
  printf(1, "wait... ");
     b32:	83 c4 08             	add    $0x8,%esp
     b35:	68 02 3f 00 00       	push   $0x3f02
     b3a:	6a 01                	push   $0x1
     b3c:	e8 43 2d 00 00       	call   3884 <printf>
  wait();
     b41:	e8 e1 2b 00 00       	call   3727 <wait>
  wait();
     b46:	e8 dc 2b 00 00       	call   3727 <wait>
  wait();
     b4b:	e8 d7 2b 00 00       	call   3727 <wait>
  printf(1, "preempt ok\n");
     b50:	83 c4 08             	add    $0x8,%esp
     b53:	68 0b 3f 00 00       	push   $0x3f0b
     b58:	6a 01                	push   $0x1
     b5a:	e8 25 2d 00 00       	call   3884 <printf>
     b5f:	83 c4 10             	add    $0x10,%esp
     b62:	eb 94                	jmp    af8 <preempt+0xcf>

00000b64 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     b64:	55                   	push   %ebp
     b65:	89 e5                	mov    %esp,%ebp
     b67:	56                   	push   %esi
     b68:	53                   	push   %ebx
  int i, pid;

  for(i = 0; i < 100; i++){
     b69:	be 00 00 00 00       	mov    $0x0,%esi
     b6e:	83 fe 63             	cmp    $0x63,%esi
     b71:	7f 4d                	jg     bc0 <exitwait+0x5c>
    pid = fork();
     b73:	e8 9f 2b 00 00       	call   3717 <fork>
     b78:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
     b7a:	85 c0                	test   %eax,%eax
     b7c:	78 10                	js     b8e <exitwait+0x2a>
      printf(1, "fork failed\n");
      return;
    }
    if(pid){
     b7e:	74 3b                	je     bbb <exitwait+0x57>
      if(wait() != pid){
     b80:	e8 a2 2b 00 00       	call   3727 <wait>
     b85:	39 d8                	cmp    %ebx,%eax
     b87:	75 1e                	jne    ba7 <exitwait+0x43>
  for(i = 0; i < 100; i++){
     b89:	83 c6 01             	add    $0x1,%esi
     b8c:	eb e0                	jmp    b6e <exitwait+0xa>
      printf(1, "fork failed\n");
     b8e:	83 ec 08             	sub    $0x8,%esp
     b91:	68 75 4a 00 00       	push   $0x4a75
     b96:	6a 01                	push   $0x1
     b98:	e8 e7 2c 00 00       	call   3884 <printf>
      return;
     b9d:	83 c4 10             	add    $0x10,%esp
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
}
     ba0:	8d 65 f8             	lea    -0x8(%ebp),%esp
     ba3:	5b                   	pop    %ebx
     ba4:	5e                   	pop    %esi
     ba5:	5d                   	pop    %ebp
     ba6:	c3                   	ret    
        printf(1, "wait wrong pid\n");
     ba7:	83 ec 08             	sub    $0x8,%esp
     baa:	68 17 3f 00 00       	push   $0x3f17
     baf:	6a 01                	push   $0x1
     bb1:	e8 ce 2c 00 00       	call   3884 <printf>
        return;
     bb6:	83 c4 10             	add    $0x10,%esp
     bb9:	eb e5                	jmp    ba0 <exitwait+0x3c>
      exit();
     bbb:	e8 5f 2b 00 00       	call   371f <exit>
  printf(1, "exitwait ok\n");
     bc0:	83 ec 08             	sub    $0x8,%esp
     bc3:	68 27 3f 00 00       	push   $0x3f27
     bc8:	6a 01                	push   $0x1
     bca:	e8 b5 2c 00 00       	call   3884 <printf>
     bcf:	83 c4 10             	add    $0x10,%esp
     bd2:	eb cc                	jmp    ba0 <exitwait+0x3c>

00000bd4 <mem>:

void
mem(void)
{
     bd4:	55                   	push   %ebp
     bd5:	89 e5                	mov    %esp,%ebp
     bd7:	57                   	push   %edi
     bd8:	56                   	push   %esi
     bd9:	53                   	push   %ebx
     bda:	83 ec 14             	sub    $0x14,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     bdd:	68 34 3f 00 00       	push   $0x3f34
     be2:	6a 01                	push   $0x1
     be4:	e8 9b 2c 00 00       	call   3884 <printf>
  ppid = getpid();
     be9:	e8 b1 2b 00 00       	call   379f <getpid>
     bee:	89 c6                	mov    %eax,%esi
  if((pid = fork()) == 0){
     bf0:	e8 22 2b 00 00       	call   3717 <fork>
     bf5:	83 c4 10             	add    $0x10,%esp
     bf8:	85 c0                	test   %eax,%eax
     bfa:	0f 85 82 00 00 00    	jne    c82 <mem+0xae>
    m1 = 0;
     c00:	bb 00 00 00 00       	mov    $0x0,%ebx
     c05:	eb 04                	jmp    c0b <mem+0x37>
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
     c07:	89 18                	mov    %ebx,(%eax)
      m1 = m2;
     c09:	89 c3                	mov    %eax,%ebx
    while((m2 = malloc(10001)) != 0){
     c0b:	83 ec 0c             	sub    $0xc,%esp
     c0e:	68 11 27 00 00       	push   $0x2711
     c13:	e8 92 2e 00 00       	call   3aaa <malloc>
     c18:	83 c4 10             	add    $0x10,%esp
     c1b:	85 c0                	test   %eax,%eax
     c1d:	75 e8                	jne    c07 <mem+0x33>
     c1f:	eb 10                	jmp    c31 <mem+0x5d>
    }
    while(m1){
      m2 = *(char**)m1;
     c21:	8b 3b                	mov    (%ebx),%edi
      free(m1);
     c23:	83 ec 0c             	sub    $0xc,%esp
     c26:	53                   	push   %ebx
     c27:	e8 be 2d 00 00       	call   39ea <free>
     c2c:	83 c4 10             	add    $0x10,%esp
      m1 = m2;
     c2f:	89 fb                	mov    %edi,%ebx
    while(m1){
     c31:	85 db                	test   %ebx,%ebx
     c33:	75 ec                	jne    c21 <mem+0x4d>
    }
    m1 = malloc(1024*20);
     c35:	83 ec 0c             	sub    $0xc,%esp
     c38:	68 00 50 00 00       	push   $0x5000
     c3d:	e8 68 2e 00 00       	call   3aaa <malloc>
    if(m1 == 0){
     c42:	83 c4 10             	add    $0x10,%esp
     c45:	85 c0                	test   %eax,%eax
     c47:	74 1d                	je     c66 <mem+0x92>
      printf(1, "couldn't allocate mem?!!\n");
      kill(ppid);
      exit();
    }
    free(m1);
     c49:	83 ec 0c             	sub    $0xc,%esp
     c4c:	50                   	push   %eax
     c4d:	e8 98 2d 00 00       	call   39ea <free>
    printf(1, "mem ok\n");
     c52:	83 c4 08             	add    $0x8,%esp
     c55:	68 58 3f 00 00       	push   $0x3f58
     c5a:	6a 01                	push   $0x1
     c5c:	e8 23 2c 00 00       	call   3884 <printf>
    exit();
     c61:	e8 b9 2a 00 00       	call   371f <exit>
      printf(1, "couldn't allocate mem?!!\n");
     c66:	83 ec 08             	sub    $0x8,%esp
     c69:	68 3e 3f 00 00       	push   $0x3f3e
     c6e:	6a 01                	push   $0x1
     c70:	e8 0f 2c 00 00       	call   3884 <printf>
      kill(ppid);
     c75:	89 34 24             	mov    %esi,(%esp)
     c78:	e8 d2 2a 00 00       	call   374f <kill>
      exit();
     c7d:	e8 9d 2a 00 00       	call   371f <exit>
  } else {
    wait();
     c82:	e8 a0 2a 00 00       	call   3727 <wait>
  }
}
     c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
     c8a:	5b                   	pop    %ebx
     c8b:	5e                   	pop    %esi
     c8c:	5f                   	pop    %edi
     c8d:	5d                   	pop    %ebp
     c8e:	c3                   	ret    

00000c8f <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     c8f:	55                   	push   %ebp
     c90:	89 e5                	mov    %esp,%ebp
     c92:	57                   	push   %edi
     c93:	56                   	push   %esi
     c94:	53                   	push   %ebx
     c95:	83 ec 24             	sub    $0x24,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     c98:	68 60 3f 00 00       	push   $0x3f60
     c9d:	6a 01                	push   $0x1
     c9f:	e8 e0 2b 00 00       	call   3884 <printf>

  unlink("sharedfd");
     ca4:	c7 04 24 6f 3f 00 00 	movl   $0x3f6f,(%esp)
     cab:	e8 bf 2a 00 00       	call   376f <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     cb0:	83 c4 08             	add    $0x8,%esp
     cb3:	68 02 02 00 00       	push   $0x202
     cb8:	68 6f 3f 00 00       	push   $0x3f6f
     cbd:	e8 9d 2a 00 00       	call   375f <open>
  if(fd < 0){
     cc2:	83 c4 10             	add    $0x10,%esp
     cc5:	85 c0                	test   %eax,%eax
     cc7:	78 4d                	js     d16 <sharedfd+0x87>
     cc9:	89 c6                	mov    %eax,%esi
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
     ccb:	e8 47 2a 00 00       	call   3717 <fork>
     cd0:	89 c7                	mov    %eax,%edi
  memset(buf, pid==0?'c':'p', sizeof(buf));
     cd2:	85 c0                	test   %eax,%eax
     cd4:	75 57                	jne    d2d <sharedfd+0x9e>
     cd6:	b8 63 00 00 00       	mov    $0x63,%eax
     cdb:	83 ec 04             	sub    $0x4,%esp
     cde:	6a 0a                	push   $0xa
     ce0:	50                   	push   %eax
     ce1:	8d 45 de             	lea    -0x22(%ebp),%eax
     ce4:	50                   	push   %eax
     ce5:	e8 fa 28 00 00       	call   35e4 <memset>
  for(i = 0; i < 1000; i++){
     cea:	83 c4 10             	add    $0x10,%esp
     ced:	bb 00 00 00 00       	mov    $0x0,%ebx
     cf2:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
     cf8:	7f 4c                	jg     d46 <sharedfd+0xb7>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     cfa:	83 ec 04             	sub    $0x4,%esp
     cfd:	6a 0a                	push   $0xa
     cff:	8d 45 de             	lea    -0x22(%ebp),%eax
     d02:	50                   	push   %eax
     d03:	56                   	push   %esi
     d04:	e8 36 2a 00 00       	call   373f <write>
     d09:	83 c4 10             	add    $0x10,%esp
     d0c:	83 f8 0a             	cmp    $0xa,%eax
     d0f:	75 23                	jne    d34 <sharedfd+0xa5>
  for(i = 0; i < 1000; i++){
     d11:	83 c3 01             	add    $0x1,%ebx
     d14:	eb dc                	jmp    cf2 <sharedfd+0x63>
    printf(1, "fstests: cannot open sharedfd for writing");
     d16:	83 ec 08             	sub    $0x8,%esp
     d19:	68 34 4c 00 00       	push   $0x4c34
     d1e:	6a 01                	push   $0x1
     d20:	e8 5f 2b 00 00       	call   3884 <printf>
    return;
     d25:	83 c4 10             	add    $0x10,%esp
     d28:	e9 e4 00 00 00       	jmp    e11 <sharedfd+0x182>
  memset(buf, pid==0?'c':'p', sizeof(buf));
     d2d:	b8 70 00 00 00       	mov    $0x70,%eax
     d32:	eb a7                	jmp    cdb <sharedfd+0x4c>
      printf(1, "fstests: write sharedfd failed\n");
     d34:	83 ec 08             	sub    $0x8,%esp
     d37:	68 60 4c 00 00       	push   $0x4c60
     d3c:	6a 01                	push   $0x1
     d3e:	e8 41 2b 00 00       	call   3884 <printf>
      break;
     d43:	83 c4 10             	add    $0x10,%esp
    }
  }
  if(pid == 0)
     d46:	85 ff                	test   %edi,%edi
     d48:	74 4d                	je     d97 <sharedfd+0x108>
    exit();
  else
    wait();
     d4a:	e8 d8 29 00 00       	call   3727 <wait>
  close(fd);
     d4f:	83 ec 0c             	sub    $0xc,%esp
     d52:	56                   	push   %esi
     d53:	e8 ef 29 00 00       	call   3747 <close>
  fd = open("sharedfd", 0);
     d58:	83 c4 08             	add    $0x8,%esp
     d5b:	6a 00                	push   $0x0
     d5d:	68 6f 3f 00 00       	push   $0x3f6f
     d62:	e8 f8 29 00 00       	call   375f <open>
     d67:	89 c7                	mov    %eax,%edi
  if(fd < 0){
     d69:	83 c4 10             	add    $0x10,%esp
     d6c:	85 c0                	test   %eax,%eax
     d6e:	78 2c                	js     d9c <sharedfd+0x10d>
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
     d70:	be 00 00 00 00       	mov    $0x0,%esi
     d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  while((n = read(fd, buf, sizeof(buf))) > 0){
     d7a:	83 ec 04             	sub    $0x4,%esp
     d7d:	6a 0a                	push   $0xa
     d7f:	8d 45 de             	lea    -0x22(%ebp),%eax
     d82:	50                   	push   %eax
     d83:	57                   	push   %edi
     d84:	e8 ae 29 00 00       	call   3737 <read>
     d89:	83 c4 10             	add    $0x10,%esp
     d8c:	85 c0                	test   %eax,%eax
     d8e:	7e 41                	jle    dd1 <sharedfd+0x142>
    for(i = 0; i < sizeof(buf); i++){
     d90:	b8 00 00 00 00       	mov    $0x0,%eax
     d95:	eb 21                	jmp    db8 <sharedfd+0x129>
    exit();
     d97:	e8 83 29 00 00       	call   371f <exit>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     d9c:	83 ec 08             	sub    $0x8,%esp
     d9f:	68 80 4c 00 00       	push   $0x4c80
     da4:	6a 01                	push   $0x1
     da6:	e8 d9 2a 00 00       	call   3884 <printf>
    return;
     dab:	83 c4 10             	add    $0x10,%esp
     dae:	eb 61                	jmp    e11 <sharedfd+0x182>
      if(buf[i] == 'c')
        nc++;
      if(buf[i] == 'p')
     db0:	80 fa 70             	cmp    $0x70,%dl
     db3:	74 17                	je     dcc <sharedfd+0x13d>
    for(i = 0; i < sizeof(buf); i++){
     db5:	83 c0 01             	add    $0x1,%eax
     db8:	83 f8 09             	cmp    $0x9,%eax
     dbb:	77 bd                	ja     d7a <sharedfd+0xeb>
      if(buf[i] == 'c')
     dbd:	0f b6 54 05 de       	movzbl -0x22(%ebp,%eax,1),%edx
     dc2:	80 fa 63             	cmp    $0x63,%dl
     dc5:	75 e9                	jne    db0 <sharedfd+0x121>
        nc++;
     dc7:	83 c3 01             	add    $0x1,%ebx
     dca:	eb e4                	jmp    db0 <sharedfd+0x121>
        np++;
     dcc:	83 c6 01             	add    $0x1,%esi
     dcf:	eb e4                	jmp    db5 <sharedfd+0x126>
    }
  }
  close(fd);
     dd1:	83 ec 0c             	sub    $0xc,%esp
     dd4:	57                   	push   %edi
     dd5:	e8 6d 29 00 00       	call   3747 <close>
  unlink("sharedfd");
     dda:	c7 04 24 6f 3f 00 00 	movl   $0x3f6f,(%esp)
     de1:	e8 89 29 00 00       	call   376f <unlink>
  if(nc == 10000 && np == 10000){
     de6:	83 c4 10             	add    $0x10,%esp
     de9:	81 fb 10 27 00 00    	cmp    $0x2710,%ebx
     def:	0f 94 c2             	sete   %dl
     df2:	81 fe 10 27 00 00    	cmp    $0x2710,%esi
     df8:	0f 94 c0             	sete   %al
     dfb:	84 c2                	test   %al,%dl
     dfd:	74 1a                	je     e19 <sharedfd+0x18a>
    printf(1, "sharedfd ok\n");
     dff:	83 ec 08             	sub    $0x8,%esp
     e02:	68 78 3f 00 00       	push   $0x3f78
     e07:	6a 01                	push   $0x1
     e09:	e8 76 2a 00 00       	call   3884 <printf>
     e0e:	83 c4 10             	add    $0x10,%esp
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    exit();
  }
}
     e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
     e14:	5b                   	pop    %ebx
     e15:	5e                   	pop    %esi
     e16:	5f                   	pop    %edi
     e17:	5d                   	pop    %ebp
     e18:	c3                   	ret    
    printf(1, "sharedfd oops %d %d\n", nc, np);
     e19:	56                   	push   %esi
     e1a:	53                   	push   %ebx
     e1b:	68 85 3f 00 00       	push   $0x3f85
     e20:	6a 01                	push   $0x1
     e22:	e8 5d 2a 00 00       	call   3884 <printf>
    exit();
     e27:	e8 f3 28 00 00       	call   371f <exit>

00000e2c <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
     e2c:	55                   	push   %ebp
     e2d:	89 e5                	mov    %esp,%ebp
     e2f:	57                   	push   %edi
     e30:	56                   	push   %esi
     e31:	53                   	push   %ebx
     e32:	83 ec 34             	sub    $0x34,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
     e35:	c7 45 d8 9a 3f 00 00 	movl   $0x3f9a,-0x28(%ebp)
     e3c:	c7 45 dc e3 40 00 00 	movl   $0x40e3,-0x24(%ebp)
     e43:	c7 45 e0 e7 40 00 00 	movl   $0x40e7,-0x20(%ebp)
     e4a:	c7 45 e4 9d 3f 00 00 	movl   $0x3f9d,-0x1c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
     e51:	68 a0 3f 00 00       	push   $0x3fa0
     e56:	6a 01                	push   $0x1
     e58:	e8 27 2a 00 00       	call   3884 <printf>

  for(pi = 0; pi < 4; pi++){
     e5d:	83 c4 10             	add    $0x10,%esp
     e60:	be 00 00 00 00       	mov    $0x0,%esi
     e65:	eb 45                	jmp    eac <fourfiles+0x80>
    fname = names[pi];
    unlink(fname);

    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
     e67:	83 ec 08             	sub    $0x8,%esp
     e6a:	68 75 4a 00 00       	push   $0x4a75
     e6f:	6a 01                	push   $0x1
     e71:	e8 0e 2a 00 00       	call   3884 <printf>
      exit();
     e76:	e8 a4 28 00 00       	call   371f <exit>
    }

    if(pid == 0){
      fd = open(fname, O_CREATE | O_RDWR);
      if(fd < 0){
        printf(1, "create failed\n");
     e7b:	83 ec 08             	sub    $0x8,%esp
     e7e:	68 3b 42 00 00       	push   $0x423b
     e83:	6a 01                	push   $0x1
     e85:	e8 fa 29 00 00       	call   3884 <printf>
        exit();
     e8a:	e8 90 28 00 00       	call   371f <exit>
      }

      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
     e8f:	83 ec 04             	sub    $0x4,%esp
     e92:	50                   	push   %eax
     e93:	68 b0 3f 00 00       	push   $0x3fb0
     e98:	6a 01                	push   $0x1
     e9a:	e8 e5 29 00 00       	call   3884 <printf>
          exit();
     e9f:	e8 7b 28 00 00       	call   371f <exit>
        }
      }
      exit();
     ea4:	e8 76 28 00 00       	call   371f <exit>
  for(pi = 0; pi < 4; pi++){
     ea9:	83 c6 01             	add    $0x1,%esi
     eac:	83 fe 03             	cmp    $0x3,%esi
     eaf:	7f 78                	jg     f29 <fourfiles+0xfd>
    fname = names[pi];
     eb1:	8b 7c b5 d8          	mov    -0x28(%ebp,%esi,4),%edi
    unlink(fname);
     eb5:	83 ec 0c             	sub    $0xc,%esp
     eb8:	57                   	push   %edi
     eb9:	e8 b1 28 00 00       	call   376f <unlink>
    pid = fork();
     ebe:	e8 54 28 00 00       	call   3717 <fork>
    if(pid < 0){
     ec3:	83 c4 10             	add    $0x10,%esp
     ec6:	85 c0                	test   %eax,%eax
     ec8:	78 9d                	js     e67 <fourfiles+0x3b>
    if(pid == 0){
     eca:	75 dd                	jne    ea9 <fourfiles+0x7d>
      fd = open(fname, O_CREATE | O_RDWR);
     ecc:	89 c3                	mov    %eax,%ebx
     ece:	83 ec 08             	sub    $0x8,%esp
     ed1:	68 02 02 00 00       	push   $0x202
     ed6:	57                   	push   %edi
     ed7:	e8 83 28 00 00       	call   375f <open>
     edc:	89 c7                	mov    %eax,%edi
      if(fd < 0){
     ede:	83 c4 10             	add    $0x10,%esp
     ee1:	85 c0                	test   %eax,%eax
     ee3:	78 96                	js     e7b <fourfiles+0x4f>
      memset(buf, '0'+pi, 512);
     ee5:	83 ec 04             	sub    $0x4,%esp
     ee8:	68 00 02 00 00       	push   $0x200
     eed:	83 c6 30             	add    $0x30,%esi
     ef0:	56                   	push   %esi
     ef1:	68 80 7a 00 00       	push   $0x7a80
     ef6:	e8 e9 26 00 00       	call   35e4 <memset>
      for(i = 0; i < 12; i++){
     efb:	83 c4 10             	add    $0x10,%esp
     efe:	83 fb 0b             	cmp    $0xb,%ebx
     f01:	7f a1                	jg     ea4 <fourfiles+0x78>
        if((n = write(fd, buf, 500)) != 500){
     f03:	83 ec 04             	sub    $0x4,%esp
     f06:	68 f4 01 00 00       	push   $0x1f4
     f0b:	68 80 7a 00 00       	push   $0x7a80
     f10:	57                   	push   %edi
     f11:	e8 29 28 00 00       	call   373f <write>
     f16:	83 c4 10             	add    $0x10,%esp
     f19:	3d f4 01 00 00       	cmp    $0x1f4,%eax
     f1e:	0f 85 6b ff ff ff    	jne    e8f <fourfiles+0x63>
      for(i = 0; i < 12; i++){
     f24:	83 c3 01             	add    $0x1,%ebx
     f27:	eb d5                	jmp    efe <fourfiles+0xd2>
    }
  }

  for(pi = 0; pi < 4; pi++){
     f29:	bb 00 00 00 00       	mov    $0x0,%ebx
     f2e:	eb 08                	jmp    f38 <fourfiles+0x10c>
    wait();
     f30:	e8 f2 27 00 00       	call   3727 <wait>
  for(pi = 0; pi < 4; pi++){
     f35:	83 c3 01             	add    $0x1,%ebx
     f38:	83 fb 03             	cmp    $0x3,%ebx
     f3b:	7e f3                	jle    f30 <fourfiles+0x104>
  }

  for(i = 0; i < 2; i++){
     f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
     f42:	eb 75                	jmp    fb9 <fourfiles+0x18d>
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
     f44:	83 ec 08             	sub    $0x8,%esp
     f47:	68 c1 3f 00 00       	push   $0x3fc1
     f4c:	6a 01                	push   $0x1
     f4e:	e8 31 29 00 00       	call   3884 <printf>
          exit();
     f53:	e8 c7 27 00 00       	call   371f <exit>
        }
      }
      total += n;
     f58:	01 7d d4             	add    %edi,-0x2c(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
     f5b:	83 ec 04             	sub    $0x4,%esp
     f5e:	68 00 20 00 00       	push   $0x2000
     f63:	68 80 7a 00 00       	push   $0x7a80
     f68:	56                   	push   %esi
     f69:	e8 c9 27 00 00       	call   3737 <read>
     f6e:	89 c7                	mov    %eax,%edi
     f70:	83 c4 10             	add    $0x10,%esp
     f73:	85 c0                	test   %eax,%eax
     f75:	7e 1c                	jle    f93 <fourfiles+0x167>
      for(j = 0; j < n; j++){
     f77:	b8 00 00 00 00       	mov    $0x0,%eax
     f7c:	39 f8                	cmp    %edi,%eax
     f7e:	7d d8                	jge    f58 <fourfiles+0x12c>
        if(buf[j] != '0'+i){
     f80:	0f be 88 80 7a 00 00 	movsbl 0x7a80(%eax),%ecx
     f87:	8d 53 30             	lea    0x30(%ebx),%edx
     f8a:	39 d1                	cmp    %edx,%ecx
     f8c:	75 b6                	jne    f44 <fourfiles+0x118>
      for(j = 0; j < n; j++){
     f8e:	83 c0 01             	add    $0x1,%eax
     f91:	eb e9                	jmp    f7c <fourfiles+0x150>
    }
    close(fd);
     f93:	83 ec 0c             	sub    $0xc,%esp
     f96:	56                   	push   %esi
     f97:	e8 ab 27 00 00       	call   3747 <close>
    if(total != 12*500){
     f9c:	83 c4 10             	add    $0x10,%esp
     f9f:	81 7d d4 70 17 00 00 	cmpl   $0x1770,-0x2c(%ebp)
     fa6:	75 39                	jne    fe1 <fourfiles+0x1b5>
      printf(1, "wrong length %d\n", total);
      exit();
    }
    unlink(fname);
     fa8:	83 ec 0c             	sub    $0xc,%esp
     fab:	ff 75 d0             	push   -0x30(%ebp)
     fae:	e8 bc 27 00 00       	call   376f <unlink>
  for(i = 0; i < 2; i++){
     fb3:	83 c3 01             	add    $0x1,%ebx
     fb6:	83 c4 10             	add    $0x10,%esp
     fb9:	83 fb 01             	cmp    $0x1,%ebx
     fbc:	7f 3a                	jg     ff8 <fourfiles+0x1cc>
    fname = names[i];
     fbe:	8b 44 9d d8          	mov    -0x28(%ebp,%ebx,4),%eax
     fc2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    fd = open(fname, 0);
     fc5:	83 ec 08             	sub    $0x8,%esp
     fc8:	6a 00                	push   $0x0
     fca:	50                   	push   %eax
     fcb:	e8 8f 27 00 00       	call   375f <open>
     fd0:	89 c6                	mov    %eax,%esi
    while((n = read(fd, buf, sizeof(buf))) > 0){
     fd2:	83 c4 10             	add    $0x10,%esp
    total = 0;
     fd5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
     fdc:	e9 7a ff ff ff       	jmp    f5b <fourfiles+0x12f>
      printf(1, "wrong length %d\n", total);
     fe1:	83 ec 04             	sub    $0x4,%esp
     fe4:	ff 75 d4             	push   -0x2c(%ebp)
     fe7:	68 cd 3f 00 00       	push   $0x3fcd
     fec:	6a 01                	push   $0x1
     fee:	e8 91 28 00 00       	call   3884 <printf>
      exit();
     ff3:	e8 27 27 00 00       	call   371f <exit>
  }

  printf(1, "fourfiles ok\n");
     ff8:	83 ec 08             	sub    $0x8,%esp
     ffb:	68 de 3f 00 00       	push   $0x3fde
    1000:	6a 01                	push   $0x1
    1002:	e8 7d 28 00 00       	call   3884 <printf>
}
    1007:	83 c4 10             	add    $0x10,%esp
    100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
    100d:	5b                   	pop    %ebx
    100e:	5e                   	pop    %esi
    100f:	5f                   	pop    %edi
    1010:	5d                   	pop    %ebp
    1011:	c3                   	ret    

00001012 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1012:	55                   	push   %ebp
    1013:	89 e5                	mov    %esp,%ebp
    1015:	56                   	push   %esi
    1016:	53                   	push   %ebx
    1017:	83 ec 28             	sub    $0x28,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    101a:	68 ec 3f 00 00       	push   $0x3fec
    101f:	6a 01                	push   $0x1
    1021:	e8 5e 28 00 00       	call   3884 <printf>

  for(pi = 0; pi < 4; pi++){
    1026:	83 c4 10             	add    $0x10,%esp
    1029:	be 00 00 00 00       	mov    $0x0,%esi
    102e:	83 fe 03             	cmp    $0x3,%esi
    1031:	0f 8f bc 00 00 00    	jg     10f3 <createdelete+0xe1>
    pid = fork();
    1037:	e8 db 26 00 00       	call   3717 <fork>
    103c:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
    103e:	85 c0                	test   %eax,%eax
    1040:	78 07                	js     1049 <createdelete+0x37>
      printf(1, "fork failed\n");
      exit();
    }

    if(pid == 0){
    1042:	74 19                	je     105d <createdelete+0x4b>
  for(pi = 0; pi < 4; pi++){
    1044:	83 c6 01             	add    $0x1,%esi
    1047:	eb e5                	jmp    102e <createdelete+0x1c>
      printf(1, "fork failed\n");
    1049:	83 ec 08             	sub    $0x8,%esp
    104c:	68 75 4a 00 00       	push   $0x4a75
    1051:	6a 01                	push   $0x1
    1053:	e8 2c 28 00 00       	call   3884 <printf>
      exit();
    1058:	e8 c2 26 00 00       	call   371f <exit>
      name[0] = 'p' + pi;
    105d:	8d 46 70             	lea    0x70(%esi),%eax
    1060:	88 45 d8             	mov    %al,-0x28(%ebp)
      name[2] = '\0';
    1063:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
      for(i = 0; i < N; i++){
    1067:	eb 17                	jmp    1080 <createdelete+0x6e>
        name[1] = '0' + i;
        fd = open(name, O_CREATE | O_RDWR);
        if(fd < 0){
          printf(1, "create failed\n");
    1069:	83 ec 08             	sub    $0x8,%esp
    106c:	68 3b 42 00 00       	push   $0x423b
    1071:	6a 01                	push   $0x1
    1073:	e8 0c 28 00 00       	call   3884 <printf>
          exit();
    1078:	e8 a2 26 00 00       	call   371f <exit>
      for(i = 0; i < N; i++){
    107d:	83 c3 01             	add    $0x1,%ebx
    1080:	83 fb 13             	cmp    $0x13,%ebx
    1083:	7f 69                	jg     10ee <createdelete+0xdc>
        name[1] = '0' + i;
    1085:	8d 43 30             	lea    0x30(%ebx),%eax
    1088:	88 45 d9             	mov    %al,-0x27(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    108b:	83 ec 08             	sub    $0x8,%esp
    108e:	68 02 02 00 00       	push   $0x202
    1093:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1096:	50                   	push   %eax
    1097:	e8 c3 26 00 00       	call   375f <open>
        if(fd < 0){
    109c:	83 c4 10             	add    $0x10,%esp
    109f:	85 c0                	test   %eax,%eax
    10a1:	78 c6                	js     1069 <createdelete+0x57>
        }
        close(fd);
    10a3:	83 ec 0c             	sub    $0xc,%esp
    10a6:	50                   	push   %eax
    10a7:	e8 9b 26 00 00       	call   3747 <close>
        if(i > 0 && (i % 2 ) == 0){
    10ac:	83 c4 10             	add    $0x10,%esp
    10af:	85 db                	test   %ebx,%ebx
    10b1:	7e ca                	jle    107d <createdelete+0x6b>
    10b3:	f6 c3 01             	test   $0x1,%bl
    10b6:	75 c5                	jne    107d <createdelete+0x6b>
          name[1] = '0' + (i / 2);
    10b8:	89 d8                	mov    %ebx,%eax
    10ba:	c1 e8 1f             	shr    $0x1f,%eax
    10bd:	01 d8                	add    %ebx,%eax
    10bf:	d1 f8                	sar    %eax
    10c1:	83 c0 30             	add    $0x30,%eax
    10c4:	88 45 d9             	mov    %al,-0x27(%ebp)
          if(unlink(name) < 0){
    10c7:	83 ec 0c             	sub    $0xc,%esp
    10ca:	8d 45 d8             	lea    -0x28(%ebp),%eax
    10cd:	50                   	push   %eax
    10ce:	e8 9c 26 00 00       	call   376f <unlink>
    10d3:	83 c4 10             	add    $0x10,%esp
    10d6:	85 c0                	test   %eax,%eax
    10d8:	79 a3                	jns    107d <createdelete+0x6b>
            printf(1, "unlink failed\n");
    10da:	83 ec 08             	sub    $0x8,%esp
    10dd:	68 ed 3b 00 00       	push   $0x3bed
    10e2:	6a 01                	push   $0x1
    10e4:	e8 9b 27 00 00       	call   3884 <printf>
            exit();
    10e9:	e8 31 26 00 00       	call   371f <exit>
          }
        }
      }
      exit();
    10ee:	e8 2c 26 00 00       	call   371f <exit>
    }
  }

  for(pi = 0; pi < 4; pi++){
    10f3:	bb 00 00 00 00       	mov    $0x0,%ebx
    10f8:	eb 08                	jmp    1102 <createdelete+0xf0>
    wait();
    10fa:	e8 28 26 00 00       	call   3727 <wait>
  for(pi = 0; pi < 4; pi++){
    10ff:	83 c3 01             	add    $0x1,%ebx
    1102:	83 fb 03             	cmp    $0x3,%ebx
    1105:	7e f3                	jle    10fa <createdelete+0xe8>
  }

  name[0] = name[1] = name[2] = 0;
    1107:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
    110b:	c6 45 d9 00          	movb   $0x0,-0x27(%ebp)
    110f:	c6 45 d8 00          	movb   $0x0,-0x28(%ebp)
  for(i = 0; i < N; i++){
    1113:	bb 00 00 00 00       	mov    $0x0,%ebx
    1118:	e9 89 00 00 00       	jmp    11a6 <createdelete+0x194>
      name[1] = '0' + i;
      fd = open(name, 0);
      if((i == 0 || i >= N/2) && fd < 0){
        printf(1, "oops createdelete %s didn't exist\n", name);
        exit();
      } else if((i >= 1 && i < N/2) && fd >= 0){
    111d:	8d 53 ff             	lea    -0x1(%ebx),%edx
    1120:	83 fa 08             	cmp    $0x8,%edx
    1123:	76 54                	jbe    1179 <createdelete+0x167>
        printf(1, "oops createdelete %s did exist\n", name);
        exit();
      }
      if(fd >= 0)
    1125:	85 c0                	test   %eax,%eax
    1127:	79 6c                	jns    1195 <createdelete+0x183>
    for(pi = 0; pi < 4; pi++){
    1129:	83 c6 01             	add    $0x1,%esi
    112c:	83 fe 03             	cmp    $0x3,%esi
    112f:	7f 72                	jg     11a3 <createdelete+0x191>
      name[0] = 'p' + pi;
    1131:	8d 46 70             	lea    0x70(%esi),%eax
    1134:	88 45 d8             	mov    %al,-0x28(%ebp)
      name[1] = '0' + i;
    1137:	8d 43 30             	lea    0x30(%ebx),%eax
    113a:	88 45 d9             	mov    %al,-0x27(%ebp)
      fd = open(name, 0);
    113d:	83 ec 08             	sub    $0x8,%esp
    1140:	6a 00                	push   $0x0
    1142:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1145:	50                   	push   %eax
    1146:	e8 14 26 00 00       	call   375f <open>
      if((i == 0 || i >= N/2) && fd < 0){
    114b:	83 c4 10             	add    $0x10,%esp
    114e:	85 db                	test   %ebx,%ebx
    1150:	0f 94 c2             	sete   %dl
    1153:	83 fb 09             	cmp    $0x9,%ebx
    1156:	0f 9f c1             	setg   %cl
    1159:	08 ca                	or     %cl,%dl
    115b:	74 c0                	je     111d <createdelete+0x10b>
    115d:	85 c0                	test   %eax,%eax
    115f:	79 bc                	jns    111d <createdelete+0x10b>
        printf(1, "oops createdelete %s didn't exist\n", name);
    1161:	83 ec 04             	sub    $0x4,%esp
    1164:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1167:	50                   	push   %eax
    1168:	68 ac 4c 00 00       	push   $0x4cac
    116d:	6a 01                	push   $0x1
    116f:	e8 10 27 00 00       	call   3884 <printf>
        exit();
    1174:	e8 a6 25 00 00       	call   371f <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1179:	85 c0                	test   %eax,%eax
    117b:	78 a8                	js     1125 <createdelete+0x113>
        printf(1, "oops createdelete %s did exist\n", name);
    117d:	83 ec 04             	sub    $0x4,%esp
    1180:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1183:	50                   	push   %eax
    1184:	68 d0 4c 00 00       	push   $0x4cd0
    1189:	6a 01                	push   $0x1
    118b:	e8 f4 26 00 00       	call   3884 <printf>
        exit();
    1190:	e8 8a 25 00 00       	call   371f <exit>
        close(fd);
    1195:	83 ec 0c             	sub    $0xc,%esp
    1198:	50                   	push   %eax
    1199:	e8 a9 25 00 00       	call   3747 <close>
    119e:	83 c4 10             	add    $0x10,%esp
    11a1:	eb 86                	jmp    1129 <createdelete+0x117>
  for(i = 0; i < N; i++){
    11a3:	83 c3 01             	add    $0x1,%ebx
    11a6:	83 fb 13             	cmp    $0x13,%ebx
    11a9:	7f 0a                	jg     11b5 <createdelete+0x1a3>
    for(pi = 0; pi < 4; pi++){
    11ab:	be 00 00 00 00       	mov    $0x0,%esi
    11b0:	e9 77 ff ff ff       	jmp    112c <createdelete+0x11a>
    }
  }

  for(i = 0; i < N; i++){
    11b5:	be 00 00 00 00       	mov    $0x0,%esi
    11ba:	eb 26                	jmp    11e2 <createdelete+0x1d0>
    for(pi = 0; pi < 4; pi++){
      name[0] = 'p' + i;
    11bc:	8d 46 70             	lea    0x70(%esi),%eax
    11bf:	88 45 d8             	mov    %al,-0x28(%ebp)
      name[1] = '0' + i;
    11c2:	8d 46 30             	lea    0x30(%esi),%eax
    11c5:	88 45 d9             	mov    %al,-0x27(%ebp)
      unlink(name);
    11c8:	83 ec 0c             	sub    $0xc,%esp
    11cb:	8d 45 d8             	lea    -0x28(%ebp),%eax
    11ce:	50                   	push   %eax
    11cf:	e8 9b 25 00 00       	call   376f <unlink>
    for(pi = 0; pi < 4; pi++){
    11d4:	83 c3 01             	add    $0x1,%ebx
    11d7:	83 c4 10             	add    $0x10,%esp
    11da:	83 fb 03             	cmp    $0x3,%ebx
    11dd:	7e dd                	jle    11bc <createdelete+0x1aa>
  for(i = 0; i < N; i++){
    11df:	83 c6 01             	add    $0x1,%esi
    11e2:	83 fe 13             	cmp    $0x13,%esi
    11e5:	7f 07                	jg     11ee <createdelete+0x1dc>
    for(pi = 0; pi < 4; pi++){
    11e7:	bb 00 00 00 00       	mov    $0x0,%ebx
    11ec:	eb ec                	jmp    11da <createdelete+0x1c8>
    }
  }

  printf(1, "createdelete ok\n");
    11ee:	83 ec 08             	sub    $0x8,%esp
    11f1:	68 ff 3f 00 00       	push   $0x3fff
    11f6:	6a 01                	push   $0x1
    11f8:	e8 87 26 00 00       	call   3884 <printf>
}
    11fd:	83 c4 10             	add    $0x10,%esp
    1200:	8d 65 f8             	lea    -0x8(%ebp),%esp
    1203:	5b                   	pop    %ebx
    1204:	5e                   	pop    %esi
    1205:	5d                   	pop    %ebp
    1206:	c3                   	ret    

00001207 <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    1207:	55                   	push   %ebp
    1208:	89 e5                	mov    %esp,%ebp
    120a:	56                   	push   %esi
    120b:	53                   	push   %ebx
  int fd, fd1;

  printf(1, "unlinkread test\n");
    120c:	83 ec 08             	sub    $0x8,%esp
    120f:	68 10 40 00 00       	push   $0x4010
    1214:	6a 01                	push   $0x1
    1216:	e8 69 26 00 00       	call   3884 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    121b:	83 c4 08             	add    $0x8,%esp
    121e:	68 02 02 00 00       	push   $0x202
    1223:	68 21 40 00 00       	push   $0x4021
    1228:	e8 32 25 00 00       	call   375f <open>
  if(fd < 0){
    122d:	83 c4 10             	add    $0x10,%esp
    1230:	85 c0                	test   %eax,%eax
    1232:	0f 88 f0 00 00 00    	js     1328 <unlinkread+0x121>
    1238:	89 c3                	mov    %eax,%ebx
    printf(1, "create unlinkread failed\n");
    exit();
  }
  write(fd, "hello", 5);
    123a:	83 ec 04             	sub    $0x4,%esp
    123d:	6a 05                	push   $0x5
    123f:	68 46 40 00 00       	push   $0x4046
    1244:	50                   	push   %eax
    1245:	e8 f5 24 00 00       	call   373f <write>
  close(fd);
    124a:	89 1c 24             	mov    %ebx,(%esp)
    124d:	e8 f5 24 00 00       	call   3747 <close>

  fd = open("unlinkread", O_RDWR);
    1252:	83 c4 08             	add    $0x8,%esp
    1255:	6a 02                	push   $0x2
    1257:	68 21 40 00 00       	push   $0x4021
    125c:	e8 fe 24 00 00       	call   375f <open>
    1261:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1263:	83 c4 10             	add    $0x10,%esp
    1266:	85 c0                	test   %eax,%eax
    1268:	0f 88 ce 00 00 00    	js     133c <unlinkread+0x135>
    printf(1, "open unlinkread failed\n");
    exit();
  }
  if(unlink("unlinkread") != 0){
    126e:	83 ec 0c             	sub    $0xc,%esp
    1271:	68 21 40 00 00       	push   $0x4021
    1276:	e8 f4 24 00 00       	call   376f <unlink>
    127b:	83 c4 10             	add    $0x10,%esp
    127e:	85 c0                	test   %eax,%eax
    1280:	0f 85 ca 00 00 00    	jne    1350 <unlinkread+0x149>
    printf(1, "unlink unlinkread failed\n");
    exit();
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1286:	83 ec 08             	sub    $0x8,%esp
    1289:	68 02 02 00 00       	push   $0x202
    128e:	68 21 40 00 00       	push   $0x4021
    1293:	e8 c7 24 00 00       	call   375f <open>
    1298:	89 c6                	mov    %eax,%esi
  write(fd1, "yyy", 3);
    129a:	83 c4 0c             	add    $0xc,%esp
    129d:	6a 03                	push   $0x3
    129f:	68 7e 40 00 00       	push   $0x407e
    12a4:	50                   	push   %eax
    12a5:	e8 95 24 00 00       	call   373f <write>
  close(fd1);
    12aa:	89 34 24             	mov    %esi,(%esp)
    12ad:	e8 95 24 00 00       	call   3747 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    12b2:	83 c4 0c             	add    $0xc,%esp
    12b5:	68 00 20 00 00       	push   $0x2000
    12ba:	68 80 7a 00 00       	push   $0x7a80
    12bf:	53                   	push   %ebx
    12c0:	e8 72 24 00 00       	call   3737 <read>
    12c5:	83 c4 10             	add    $0x10,%esp
    12c8:	83 f8 05             	cmp    $0x5,%eax
    12cb:	0f 85 93 00 00 00    	jne    1364 <unlinkread+0x15d>
    printf(1, "unlinkread read failed");
    exit();
  }
  if(buf[0] != 'h'){
    12d1:	80 3d 80 7a 00 00 68 	cmpb   $0x68,0x7a80
    12d8:	0f 85 9a 00 00 00    	jne    1378 <unlinkread+0x171>
    printf(1, "unlinkread wrong data\n");
    exit();
  }
  if(write(fd, buf, 10) != 10){
    12de:	83 ec 04             	sub    $0x4,%esp
    12e1:	6a 0a                	push   $0xa
    12e3:	68 80 7a 00 00       	push   $0x7a80
    12e8:	53                   	push   %ebx
    12e9:	e8 51 24 00 00       	call   373f <write>
    12ee:	83 c4 10             	add    $0x10,%esp
    12f1:	83 f8 0a             	cmp    $0xa,%eax
    12f4:	0f 85 92 00 00 00    	jne    138c <unlinkread+0x185>
    printf(1, "unlinkread write failed\n");
    exit();
  }
  close(fd);
    12fa:	83 ec 0c             	sub    $0xc,%esp
    12fd:	53                   	push   %ebx
    12fe:	e8 44 24 00 00       	call   3747 <close>
  unlink("unlinkread");
    1303:	c7 04 24 21 40 00 00 	movl   $0x4021,(%esp)
    130a:	e8 60 24 00 00       	call   376f <unlink>
  printf(1, "unlinkread ok\n");
    130f:	83 c4 08             	add    $0x8,%esp
    1312:	68 c9 40 00 00       	push   $0x40c9
    1317:	6a 01                	push   $0x1
    1319:	e8 66 25 00 00       	call   3884 <printf>
}
    131e:	83 c4 10             	add    $0x10,%esp
    1321:	8d 65 f8             	lea    -0x8(%ebp),%esp
    1324:	5b                   	pop    %ebx
    1325:	5e                   	pop    %esi
    1326:	5d                   	pop    %ebp
    1327:	c3                   	ret    
    printf(1, "create unlinkread failed\n");
    1328:	83 ec 08             	sub    $0x8,%esp
    132b:	68 2c 40 00 00       	push   $0x402c
    1330:	6a 01                	push   $0x1
    1332:	e8 4d 25 00 00       	call   3884 <printf>
    exit();
    1337:	e8 e3 23 00 00       	call   371f <exit>
    printf(1, "open unlinkread failed\n");
    133c:	83 ec 08             	sub    $0x8,%esp
    133f:	68 4c 40 00 00       	push   $0x404c
    1344:	6a 01                	push   $0x1
    1346:	e8 39 25 00 00       	call   3884 <printf>
    exit();
    134b:	e8 cf 23 00 00       	call   371f <exit>
    printf(1, "unlink unlinkread failed\n");
    1350:	83 ec 08             	sub    $0x8,%esp
    1353:	68 64 40 00 00       	push   $0x4064
    1358:	6a 01                	push   $0x1
    135a:	e8 25 25 00 00       	call   3884 <printf>
    exit();
    135f:	e8 bb 23 00 00       	call   371f <exit>
    printf(1, "unlinkread read failed");
    1364:	83 ec 08             	sub    $0x8,%esp
    1367:	68 82 40 00 00       	push   $0x4082
    136c:	6a 01                	push   $0x1
    136e:	e8 11 25 00 00       	call   3884 <printf>
    exit();
    1373:	e8 a7 23 00 00       	call   371f <exit>
    printf(1, "unlinkread wrong data\n");
    1378:	83 ec 08             	sub    $0x8,%esp
    137b:	68 99 40 00 00       	push   $0x4099
    1380:	6a 01                	push   $0x1
    1382:	e8 fd 24 00 00       	call   3884 <printf>
    exit();
    1387:	e8 93 23 00 00       	call   371f <exit>
    printf(1, "unlinkread write failed\n");
    138c:	83 ec 08             	sub    $0x8,%esp
    138f:	68 b0 40 00 00       	push   $0x40b0
    1394:	6a 01                	push   $0x1
    1396:	e8 e9 24 00 00       	call   3884 <printf>
    exit();
    139b:	e8 7f 23 00 00       	call   371f <exit>

000013a0 <linktest>:

void
linktest(void)
{
    13a0:	55                   	push   %ebp
    13a1:	89 e5                	mov    %esp,%ebp
    13a3:	53                   	push   %ebx
    13a4:	83 ec 0c             	sub    $0xc,%esp
  int fd;

  printf(1, "linktest\n");
    13a7:	68 d8 40 00 00       	push   $0x40d8
    13ac:	6a 01                	push   $0x1
    13ae:	e8 d1 24 00 00       	call   3884 <printf>

  unlink("lf1");
    13b3:	c7 04 24 e2 40 00 00 	movl   $0x40e2,(%esp)
    13ba:	e8 b0 23 00 00       	call   376f <unlink>
  unlink("lf2");
    13bf:	c7 04 24 e6 40 00 00 	movl   $0x40e6,(%esp)
    13c6:	e8 a4 23 00 00       	call   376f <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    13cb:	83 c4 08             	add    $0x8,%esp
    13ce:	68 02 02 00 00       	push   $0x202
    13d3:	68 e2 40 00 00       	push   $0x40e2
    13d8:	e8 82 23 00 00       	call   375f <open>
  if(fd < 0){
    13dd:	83 c4 10             	add    $0x10,%esp
    13e0:	85 c0                	test   %eax,%eax
    13e2:	0f 88 2a 01 00 00    	js     1512 <linktest+0x172>
    13e8:	89 c3                	mov    %eax,%ebx
    printf(1, "create lf1 failed\n");
    exit();
  }
  if(write(fd, "hello", 5) != 5){
    13ea:	83 ec 04             	sub    $0x4,%esp
    13ed:	6a 05                	push   $0x5
    13ef:	68 46 40 00 00       	push   $0x4046
    13f4:	50                   	push   %eax
    13f5:	e8 45 23 00 00       	call   373f <write>
    13fa:	83 c4 10             	add    $0x10,%esp
    13fd:	83 f8 05             	cmp    $0x5,%eax
    1400:	0f 85 20 01 00 00    	jne    1526 <linktest+0x186>
    printf(1, "write lf1 failed\n");
    exit();
  }
  close(fd);
    1406:	83 ec 0c             	sub    $0xc,%esp
    1409:	53                   	push   %ebx
    140a:	e8 38 23 00 00       	call   3747 <close>

  if(link("lf1", "lf2") < 0){
    140f:	83 c4 08             	add    $0x8,%esp
    1412:	68 e6 40 00 00       	push   $0x40e6
    1417:	68 e2 40 00 00       	push   $0x40e2
    141c:	e8 5e 23 00 00       	call   377f <link>
    1421:	83 c4 10             	add    $0x10,%esp
    1424:	85 c0                	test   %eax,%eax
    1426:	0f 88 0e 01 00 00    	js     153a <linktest+0x19a>
    printf(1, "link lf1 lf2 failed\n");
    exit();
  }
  unlink("lf1");
    142c:	83 ec 0c             	sub    $0xc,%esp
    142f:	68 e2 40 00 00       	push   $0x40e2
    1434:	e8 36 23 00 00       	call   376f <unlink>

  if(open("lf1", 0) >= 0){
    1439:	83 c4 08             	add    $0x8,%esp
    143c:	6a 00                	push   $0x0
    143e:	68 e2 40 00 00       	push   $0x40e2
    1443:	e8 17 23 00 00       	call   375f <open>
    1448:	83 c4 10             	add    $0x10,%esp
    144b:	85 c0                	test   %eax,%eax
    144d:	0f 89 fb 00 00 00    	jns    154e <linktest+0x1ae>
    printf(1, "unlinked lf1 but it is still there!\n");
    exit();
  }

  fd = open("lf2", 0);
    1453:	83 ec 08             	sub    $0x8,%esp
    1456:	6a 00                	push   $0x0
    1458:	68 e6 40 00 00       	push   $0x40e6
    145d:	e8 fd 22 00 00       	call   375f <open>
    1462:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1464:	83 c4 10             	add    $0x10,%esp
    1467:	85 c0                	test   %eax,%eax
    1469:	0f 88 f3 00 00 00    	js     1562 <linktest+0x1c2>
    printf(1, "open lf2 failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    146f:	83 ec 04             	sub    $0x4,%esp
    1472:	68 00 20 00 00       	push   $0x2000
    1477:	68 80 7a 00 00       	push   $0x7a80
    147c:	50                   	push   %eax
    147d:	e8 b5 22 00 00       	call   3737 <read>
    1482:	83 c4 10             	add    $0x10,%esp
    1485:	83 f8 05             	cmp    $0x5,%eax
    1488:	0f 85 e8 00 00 00    	jne    1576 <linktest+0x1d6>
    printf(1, "read lf2 failed\n");
    exit();
  }
  close(fd);
    148e:	83 ec 0c             	sub    $0xc,%esp
    1491:	53                   	push   %ebx
    1492:	e8 b0 22 00 00       	call   3747 <close>

  if(link("lf2", "lf2") >= 0){
    1497:	83 c4 08             	add    $0x8,%esp
    149a:	68 e6 40 00 00       	push   $0x40e6
    149f:	68 e6 40 00 00       	push   $0x40e6
    14a4:	e8 d6 22 00 00       	call   377f <link>
    14a9:	83 c4 10             	add    $0x10,%esp
    14ac:	85 c0                	test   %eax,%eax
    14ae:	0f 89 d6 00 00 00    	jns    158a <linktest+0x1ea>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    exit();
  }

  unlink("lf2");
    14b4:	83 ec 0c             	sub    $0xc,%esp
    14b7:	68 e6 40 00 00       	push   $0x40e6
    14bc:	e8 ae 22 00 00       	call   376f <unlink>
  if(link("lf2", "lf1") >= 0){
    14c1:	83 c4 08             	add    $0x8,%esp
    14c4:	68 e2 40 00 00       	push   $0x40e2
    14c9:	68 e6 40 00 00       	push   $0x40e6
    14ce:	e8 ac 22 00 00       	call   377f <link>
    14d3:	83 c4 10             	add    $0x10,%esp
    14d6:	85 c0                	test   %eax,%eax
    14d8:	0f 89 c0 00 00 00    	jns    159e <linktest+0x1fe>
    printf(1, "link non-existant succeeded! oops\n");
    exit();
  }

  if(link(".", "lf1") >= 0){
    14de:	83 ec 08             	sub    $0x8,%esp
    14e1:	68 e2 40 00 00       	push   $0x40e2
    14e6:	68 aa 43 00 00       	push   $0x43aa
    14eb:	e8 8f 22 00 00       	call   377f <link>
    14f0:	83 c4 10             	add    $0x10,%esp
    14f3:	85 c0                	test   %eax,%eax
    14f5:	0f 89 b7 00 00 00    	jns    15b2 <linktest+0x212>
    printf(1, "link . lf1 succeeded! oops\n");
    exit();
  }

  printf(1, "linktest ok\n");
    14fb:	83 ec 08             	sub    $0x8,%esp
    14fe:	68 80 41 00 00       	push   $0x4180
    1503:	6a 01                	push   $0x1
    1505:	e8 7a 23 00 00       	call   3884 <printf>
}
    150a:	83 c4 10             	add    $0x10,%esp
    150d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1510:	c9                   	leave  
    1511:	c3                   	ret    
    printf(1, "create lf1 failed\n");
    1512:	83 ec 08             	sub    $0x8,%esp
    1515:	68 ea 40 00 00       	push   $0x40ea
    151a:	6a 01                	push   $0x1
    151c:	e8 63 23 00 00       	call   3884 <printf>
    exit();
    1521:	e8 f9 21 00 00       	call   371f <exit>
    printf(1, "write lf1 failed\n");
    1526:	83 ec 08             	sub    $0x8,%esp
    1529:	68 fd 40 00 00       	push   $0x40fd
    152e:	6a 01                	push   $0x1
    1530:	e8 4f 23 00 00       	call   3884 <printf>
    exit();
    1535:	e8 e5 21 00 00       	call   371f <exit>
    printf(1, "link lf1 lf2 failed\n");
    153a:	83 ec 08             	sub    $0x8,%esp
    153d:	68 0f 41 00 00       	push   $0x410f
    1542:	6a 01                	push   $0x1
    1544:	e8 3b 23 00 00       	call   3884 <printf>
    exit();
    1549:	e8 d1 21 00 00       	call   371f <exit>
    printf(1, "unlinked lf1 but it is still there!\n");
    154e:	83 ec 08             	sub    $0x8,%esp
    1551:	68 f0 4c 00 00       	push   $0x4cf0
    1556:	6a 01                	push   $0x1
    1558:	e8 27 23 00 00       	call   3884 <printf>
    exit();
    155d:	e8 bd 21 00 00       	call   371f <exit>
    printf(1, "open lf2 failed\n");
    1562:	83 ec 08             	sub    $0x8,%esp
    1565:	68 24 41 00 00       	push   $0x4124
    156a:	6a 01                	push   $0x1
    156c:	e8 13 23 00 00       	call   3884 <printf>
    exit();
    1571:	e8 a9 21 00 00       	call   371f <exit>
    printf(1, "read lf2 failed\n");
    1576:	83 ec 08             	sub    $0x8,%esp
    1579:	68 35 41 00 00       	push   $0x4135
    157e:	6a 01                	push   $0x1
    1580:	e8 ff 22 00 00       	call   3884 <printf>
    exit();
    1585:	e8 95 21 00 00       	call   371f <exit>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    158a:	83 ec 08             	sub    $0x8,%esp
    158d:	68 46 41 00 00       	push   $0x4146
    1592:	6a 01                	push   $0x1
    1594:	e8 eb 22 00 00       	call   3884 <printf>
    exit();
    1599:	e8 81 21 00 00       	call   371f <exit>
    printf(1, "link non-existant succeeded! oops\n");
    159e:	83 ec 08             	sub    $0x8,%esp
    15a1:	68 18 4d 00 00       	push   $0x4d18
    15a6:	6a 01                	push   $0x1
    15a8:	e8 d7 22 00 00       	call   3884 <printf>
    exit();
    15ad:	e8 6d 21 00 00       	call   371f <exit>
    printf(1, "link . lf1 succeeded! oops\n");
    15b2:	83 ec 08             	sub    $0x8,%esp
    15b5:	68 64 41 00 00       	push   $0x4164
    15ba:	6a 01                	push   $0x1
    15bc:	e8 c3 22 00 00       	call   3884 <printf>
    exit();
    15c1:	e8 59 21 00 00       	call   371f <exit>

000015c6 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    15c6:	55                   	push   %ebp
    15c7:	89 e5                	mov    %esp,%ebp
    15c9:	57                   	push   %edi
    15ca:	56                   	push   %esi
    15cb:	53                   	push   %ebx
    15cc:	83 ec 54             	sub    $0x54,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    15cf:	68 8d 41 00 00       	push   $0x418d
    15d4:	6a 01                	push   $0x1
    15d6:	e8 a9 22 00 00       	call   3884 <printf>
  file[0] = 'C';
    15db:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    15df:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    15e3:	83 c4 10             	add    $0x10,%esp
    15e6:	bb 00 00 00 00       	mov    $0x0,%ebx
    15eb:	eb 5e                	jmp    164b <concreate+0x85>
    file[1] = '0' + i;
    unlink(file);
    pid = fork();
    if(pid && (i % 3) == 1){
      link("C0", file);
    } else if(pid == 0 && (i % 5) == 1){
    15ed:	85 f6                	test   %esi,%esi
    15ef:	75 22                	jne    1613 <concreate+0x4d>
    15f1:	ba 67 66 66 66       	mov    $0x66666667,%edx
    15f6:	89 d8                	mov    %ebx,%eax
    15f8:	f7 ea                	imul   %edx
    15fa:	d1 fa                	sar    %edx
    15fc:	89 d8                	mov    %ebx,%eax
    15fe:	c1 f8 1f             	sar    $0x1f,%eax
    1601:	29 c2                	sub    %eax,%edx
    1603:	8d 04 92             	lea    (%edx,%edx,4),%eax
    1606:	89 da                	mov    %ebx,%edx
    1608:	29 c2                	sub    %eax,%edx
    160a:	83 fa 01             	cmp    $0x1,%edx
    160d:	0f 84 9b 00 00 00    	je     16ae <concreate+0xe8>
      link("C0", file);
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    1613:	83 ec 08             	sub    $0x8,%esp
    1616:	68 02 02 00 00       	push   $0x202
    161b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    161e:	50                   	push   %eax
    161f:	e8 3b 21 00 00       	call   375f <open>
      if(fd < 0){
    1624:	83 c4 10             	add    $0x10,%esp
    1627:	85 c0                	test   %eax,%eax
    1629:	0f 88 98 00 00 00    	js     16c7 <concreate+0x101>
        printf(1, "concreate create %s failed\n", file);
        exit();
      }
      close(fd);
    162f:	83 ec 0c             	sub    $0xc,%esp
    1632:	50                   	push   %eax
    1633:	e8 0f 21 00 00       	call   3747 <close>
    1638:	83 c4 10             	add    $0x10,%esp
    }
    if(pid == 0)
    163b:	85 f6                	test   %esi,%esi
    163d:	0f 84 9c 00 00 00    	je     16df <concreate+0x119>
      exit();
    else
      wait();
    1643:	e8 df 20 00 00       	call   3727 <wait>
  for(i = 0; i < 40; i++){
    1648:	83 c3 01             	add    $0x1,%ebx
    164b:	83 fb 27             	cmp    $0x27,%ebx
    164e:	0f 8f 90 00 00 00    	jg     16e4 <concreate+0x11e>
    file[1] = '0' + i;
    1654:	8d 43 30             	lea    0x30(%ebx),%eax
    1657:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    165a:	83 ec 0c             	sub    $0xc,%esp
    165d:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1660:	50                   	push   %eax
    1661:	e8 09 21 00 00       	call   376f <unlink>
    pid = fork();
    1666:	e8 ac 20 00 00       	call   3717 <fork>
    166b:	89 c6                	mov    %eax,%esi
    if(pid && (i % 3) == 1){
    166d:	83 c4 10             	add    $0x10,%esp
    1670:	85 c0                	test   %eax,%eax
    1672:	0f 84 75 ff ff ff    	je     15ed <concreate+0x27>
    1678:	ba 56 55 55 55       	mov    $0x55555556,%edx
    167d:	89 d8                	mov    %ebx,%eax
    167f:	f7 ea                	imul   %edx
    1681:	89 d8                	mov    %ebx,%eax
    1683:	c1 f8 1f             	sar    $0x1f,%eax
    1686:	29 c2                	sub    %eax,%edx
    1688:	8d 04 52             	lea    (%edx,%edx,2),%eax
    168b:	89 da                	mov    %ebx,%edx
    168d:	29 c2                	sub    %eax,%edx
    168f:	83 fa 01             	cmp    $0x1,%edx
    1692:	0f 85 55 ff ff ff    	jne    15ed <concreate+0x27>
      link("C0", file);
    1698:	83 ec 08             	sub    $0x8,%esp
    169b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    169e:	50                   	push   %eax
    169f:	68 9d 41 00 00       	push   $0x419d
    16a4:	e8 d6 20 00 00       	call   377f <link>
    16a9:	83 c4 10             	add    $0x10,%esp
    16ac:	eb 8d                	jmp    163b <concreate+0x75>
      link("C0", file);
    16ae:	83 ec 08             	sub    $0x8,%esp
    16b1:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    16b4:	50                   	push   %eax
    16b5:	68 9d 41 00 00       	push   $0x419d
    16ba:	e8 c0 20 00 00       	call   377f <link>
    16bf:	83 c4 10             	add    $0x10,%esp
    16c2:	e9 74 ff ff ff       	jmp    163b <concreate+0x75>
        printf(1, "concreate create %s failed\n", file);
    16c7:	83 ec 04             	sub    $0x4,%esp
    16ca:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    16cd:	50                   	push   %eax
    16ce:	68 a0 41 00 00       	push   $0x41a0
    16d3:	6a 01                	push   $0x1
    16d5:	e8 aa 21 00 00       	call   3884 <printf>
        exit();
    16da:	e8 40 20 00 00       	call   371f <exit>
      exit();
    16df:	e8 3b 20 00 00       	call   371f <exit>
  }

  memset(fa, 0, sizeof(fa));
    16e4:	83 ec 04             	sub    $0x4,%esp
    16e7:	6a 28                	push   $0x28
    16e9:	6a 00                	push   $0x0
    16eb:	8d 45 bd             	lea    -0x43(%ebp),%eax
    16ee:	50                   	push   %eax
    16ef:	e8 f0 1e 00 00       	call   35e4 <memset>
  fd = open(".", 0);
    16f4:	83 c4 08             	add    $0x8,%esp
    16f7:	6a 00                	push   $0x0
    16f9:	68 aa 43 00 00       	push   $0x43aa
    16fe:	e8 5c 20 00 00       	call   375f <open>
    1703:	89 c3                	mov    %eax,%ebx
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    1705:	83 c4 10             	add    $0x10,%esp
  n = 0;
    1708:	be 00 00 00 00       	mov    $0x0,%esi
  while(read(fd, &de, sizeof(de)) > 0){
    170d:	83 ec 04             	sub    $0x4,%esp
    1710:	6a 10                	push   $0x10
    1712:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1715:	50                   	push   %eax
    1716:	53                   	push   %ebx
    1717:	e8 1b 20 00 00       	call   3737 <read>
    171c:	83 c4 10             	add    $0x10,%esp
    171f:	85 c0                	test   %eax,%eax
    1721:	7e 60                	jle    1783 <concreate+0x1bd>
    if(de.inum == 0)
    1723:	66 83 7d ac 00       	cmpw   $0x0,-0x54(%ebp)
    1728:	74 e3                	je     170d <concreate+0x147>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    172a:	80 7d ae 43          	cmpb   $0x43,-0x52(%ebp)
    172e:	75 dd                	jne    170d <concreate+0x147>
    1730:	80 7d b0 00          	cmpb   $0x0,-0x50(%ebp)
    1734:	75 d7                	jne    170d <concreate+0x147>
      i = de.name[1] - '0';
    1736:	0f be 45 af          	movsbl -0x51(%ebp),%eax
    173a:	83 e8 30             	sub    $0x30,%eax
      if(i < 0 || i >= sizeof(fa)){
    173d:	83 f8 27             	cmp    $0x27,%eax
    1740:	77 11                	ja     1753 <concreate+0x18d>
        printf(1, "concreate weird file %s\n", de.name);
        exit();
      }
      if(fa[i]){
    1742:	80 7c 05 bd 00       	cmpb   $0x0,-0x43(%ebp,%eax,1)
    1747:	75 22                	jne    176b <concreate+0x1a5>
        printf(1, "concreate duplicate file %s\n", de.name);
        exit();
      }
      fa[i] = 1;
    1749:	c6 44 05 bd 01       	movb   $0x1,-0x43(%ebp,%eax,1)
      n++;
    174e:	83 c6 01             	add    $0x1,%esi
    1751:	eb ba                	jmp    170d <concreate+0x147>
        printf(1, "concreate weird file %s\n", de.name);
    1753:	83 ec 04             	sub    $0x4,%esp
    1756:	8d 45 ae             	lea    -0x52(%ebp),%eax
    1759:	50                   	push   %eax
    175a:	68 bc 41 00 00       	push   $0x41bc
    175f:	6a 01                	push   $0x1
    1761:	e8 1e 21 00 00       	call   3884 <printf>
        exit();
    1766:	e8 b4 1f 00 00       	call   371f <exit>
        printf(1, "concreate duplicate file %s\n", de.name);
    176b:	83 ec 04             	sub    $0x4,%esp
    176e:	8d 45 ae             	lea    -0x52(%ebp),%eax
    1771:	50                   	push   %eax
    1772:	68 d5 41 00 00       	push   $0x41d5
    1777:	6a 01                	push   $0x1
    1779:	e8 06 21 00 00       	call   3884 <printf>
        exit();
    177e:	e8 9c 1f 00 00       	call   371f <exit>
    }
  }
  close(fd);
    1783:	83 ec 0c             	sub    $0xc,%esp
    1786:	53                   	push   %ebx
    1787:	e8 bb 1f 00 00       	call   3747 <close>

  if(n != 40){
    178c:	83 c4 10             	add    $0x10,%esp
    178f:	83 fe 28             	cmp    $0x28,%esi
    1792:	75 0a                	jne    179e <concreate+0x1d8>
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    1794:	bb 00 00 00 00       	mov    $0x0,%ebx
    1799:	e9 86 00 00 00       	jmp    1824 <concreate+0x25e>
    printf(1, "concreate not enough files in directory listing\n");
    179e:	83 ec 08             	sub    $0x8,%esp
    17a1:	68 3c 4d 00 00       	push   $0x4d3c
    17a6:	6a 01                	push   $0x1
    17a8:	e8 d7 20 00 00       	call   3884 <printf>
    exit();
    17ad:	e8 6d 1f 00 00       	call   371f <exit>
    file[1] = '0' + i;
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
    17b2:	83 ec 08             	sub    $0x8,%esp
    17b5:	68 75 4a 00 00       	push   $0x4a75
    17ba:	6a 01                	push   $0x1
    17bc:	e8 c3 20 00 00       	call   3884 <printf>
      exit();
    17c1:	e8 59 1f 00 00       	call   371f <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
       ((i % 3) == 1 && pid != 0)){
      close(open(file, 0));
    17c6:	83 ec 08             	sub    $0x8,%esp
    17c9:	6a 00                	push   $0x0
    17cb:	8d 7d e5             	lea    -0x1b(%ebp),%edi
    17ce:	57                   	push   %edi
    17cf:	e8 8b 1f 00 00       	call   375f <open>
    17d4:	89 04 24             	mov    %eax,(%esp)
    17d7:	e8 6b 1f 00 00       	call   3747 <close>
      close(open(file, 0));
    17dc:	83 c4 08             	add    $0x8,%esp
    17df:	6a 00                	push   $0x0
    17e1:	57                   	push   %edi
    17e2:	e8 78 1f 00 00       	call   375f <open>
    17e7:	89 04 24             	mov    %eax,(%esp)
    17ea:	e8 58 1f 00 00       	call   3747 <close>
      close(open(file, 0));
    17ef:	83 c4 08             	add    $0x8,%esp
    17f2:	6a 00                	push   $0x0
    17f4:	57                   	push   %edi
    17f5:	e8 65 1f 00 00       	call   375f <open>
    17fa:	89 04 24             	mov    %eax,(%esp)
    17fd:	e8 45 1f 00 00       	call   3747 <close>
      close(open(file, 0));
    1802:	83 c4 08             	add    $0x8,%esp
    1805:	6a 00                	push   $0x0
    1807:	57                   	push   %edi
    1808:	e8 52 1f 00 00       	call   375f <open>
    180d:	89 04 24             	mov    %eax,(%esp)
    1810:	e8 32 1f 00 00       	call   3747 <close>
    1815:	83 c4 10             	add    $0x10,%esp
      unlink(file);
      unlink(file);
      unlink(file);
      unlink(file);
    }
    if(pid == 0)
    1818:	85 f6                	test   %esi,%esi
    181a:	74 79                	je     1895 <concreate+0x2cf>
      exit();
    else
      wait();
    181c:	e8 06 1f 00 00       	call   3727 <wait>
  for(i = 0; i < 40; i++){
    1821:	83 c3 01             	add    $0x1,%ebx
    1824:	83 fb 27             	cmp    $0x27,%ebx
    1827:	7f 71                	jg     189a <concreate+0x2d4>
    file[1] = '0' + i;
    1829:	8d 43 30             	lea    0x30(%ebx),%eax
    182c:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    182f:	e8 e3 1e 00 00       	call   3717 <fork>
    1834:	89 c6                	mov    %eax,%esi
    if(pid < 0){
    1836:	85 c0                	test   %eax,%eax
    1838:	0f 88 74 ff ff ff    	js     17b2 <concreate+0x1ec>
    if(((i % 3) == 0 && pid == 0) ||
    183e:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1843:	89 d8                	mov    %ebx,%eax
    1845:	f7 ea                	imul   %edx
    1847:	89 d8                	mov    %ebx,%eax
    1849:	c1 f8 1f             	sar    $0x1f,%eax
    184c:	29 c2                	sub    %eax,%edx
    184e:	8d 04 52             	lea    (%edx,%edx,2),%eax
    1851:	89 da                	mov    %ebx,%edx
    1853:	29 c2                	sub    %eax,%edx
    1855:	89 d0                	mov    %edx,%eax
    1857:	09 f0                	or     %esi,%eax
    1859:	0f 84 67 ff ff ff    	je     17c6 <concreate+0x200>
    185f:	83 fa 01             	cmp    $0x1,%edx
    1862:	75 08                	jne    186c <concreate+0x2a6>
       ((i % 3) == 1 && pid != 0)){
    1864:	85 f6                	test   %esi,%esi
    1866:	0f 85 5a ff ff ff    	jne    17c6 <concreate+0x200>
      unlink(file);
    186c:	83 ec 0c             	sub    $0xc,%esp
    186f:	8d 7d e5             	lea    -0x1b(%ebp),%edi
    1872:	57                   	push   %edi
    1873:	e8 f7 1e 00 00       	call   376f <unlink>
      unlink(file);
    1878:	89 3c 24             	mov    %edi,(%esp)
    187b:	e8 ef 1e 00 00       	call   376f <unlink>
      unlink(file);
    1880:	89 3c 24             	mov    %edi,(%esp)
    1883:	e8 e7 1e 00 00       	call   376f <unlink>
      unlink(file);
    1888:	89 3c 24             	mov    %edi,(%esp)
    188b:	e8 df 1e 00 00       	call   376f <unlink>
    1890:	83 c4 10             	add    $0x10,%esp
    1893:	eb 83                	jmp    1818 <concreate+0x252>
      exit();
    1895:	e8 85 1e 00 00       	call   371f <exit>
  }

  printf(1, "concreate ok\n");
    189a:	83 ec 08             	sub    $0x8,%esp
    189d:	68 f2 41 00 00       	push   $0x41f2
    18a2:	6a 01                	push   $0x1
    18a4:	e8 db 1f 00 00       	call   3884 <printf>
}
    18a9:	83 c4 10             	add    $0x10,%esp
    18ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
    18af:	5b                   	pop    %ebx
    18b0:	5e                   	pop    %esi
    18b1:	5f                   	pop    %edi
    18b2:	5d                   	pop    %ebp
    18b3:	c3                   	ret    

000018b4 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    18b4:	55                   	push   %ebp
    18b5:	89 e5                	mov    %esp,%ebp
    18b7:	57                   	push   %edi
    18b8:	56                   	push   %esi
    18b9:	53                   	push   %ebx
    18ba:	83 ec 14             	sub    $0x14,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    18bd:	68 00 42 00 00       	push   $0x4200
    18c2:	6a 01                	push   $0x1
    18c4:	e8 bb 1f 00 00       	call   3884 <printf>

  unlink("x");
    18c9:	c7 04 24 8d 44 00 00 	movl   $0x448d,(%esp)
    18d0:	e8 9a 1e 00 00       	call   376f <unlink>
  pid = fork();
    18d5:	e8 3d 1e 00 00       	call   3717 <fork>
  if(pid < 0){
    18da:	83 c4 10             	add    $0x10,%esp
    18dd:	85 c0                	test   %eax,%eax
    18df:	78 10                	js     18f1 <linkunlink+0x3d>
    18e1:	89 c7                	mov    %eax,%edi
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
    18e3:	74 20                	je     1905 <linkunlink+0x51>
    18e5:	bb 01 00 00 00       	mov    $0x1,%ebx
    18ea:	be 00 00 00 00       	mov    $0x0,%esi
    18ef:	eb 3b                	jmp    192c <linkunlink+0x78>
    printf(1, "fork failed\n");
    18f1:	83 ec 08             	sub    $0x8,%esp
    18f4:	68 75 4a 00 00       	push   $0x4a75
    18f9:	6a 01                	push   $0x1
    18fb:	e8 84 1f 00 00       	call   3884 <printf>
    exit();
    1900:	e8 1a 1e 00 00       	call   371f <exit>
  unsigned int x = (pid ? 1 : 97);
    1905:	bb 61 00 00 00       	mov    $0x61,%ebx
    190a:	eb de                	jmp    18ea <linkunlink+0x36>
  for(i = 0; i < 100; i++){
    x = x * 1103515245 + 12345;
    if((x % 3) == 0){
      close(open("x", O_RDWR | O_CREATE));
    190c:	83 ec 08             	sub    $0x8,%esp
    190f:	68 02 02 00 00       	push   $0x202
    1914:	68 8d 44 00 00       	push   $0x448d
    1919:	e8 41 1e 00 00       	call   375f <open>
    191e:	89 04 24             	mov    %eax,(%esp)
    1921:	e8 21 1e 00 00       	call   3747 <close>
    1926:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 100; i++){
    1929:	83 c6 01             	add    $0x1,%esi
    192c:	83 fe 63             	cmp    $0x63,%esi
    192f:	7f 52                	jg     1983 <linkunlink+0xcf>
    x = x * 1103515245 + 12345;
    1931:	69 db 6d 4e c6 41    	imul   $0x41c64e6d,%ebx,%ebx
    1937:	81 c3 39 30 00 00    	add    $0x3039,%ebx
    if((x % 3) == 0){
    193d:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1942:	89 d8                	mov    %ebx,%eax
    1944:	f7 e2                	mul    %edx
    1946:	89 d0                	mov    %edx,%eax
    1948:	d1 e8                	shr    %eax
    194a:	83 e2 fe             	and    $0xfffffffe,%edx
    194d:	01 c2                	add    %eax,%edx
    194f:	89 d8                	mov    %ebx,%eax
    1951:	29 d0                	sub    %edx,%eax
    1953:	74 b7                	je     190c <linkunlink+0x58>
    } else if((x % 3) == 1){
    1955:	83 f8 01             	cmp    $0x1,%eax
    1958:	74 12                	je     196c <linkunlink+0xb8>
      link("cat", "x");
    } else {
      unlink("x");
    195a:	83 ec 0c             	sub    $0xc,%esp
    195d:	68 8d 44 00 00       	push   $0x448d
    1962:	e8 08 1e 00 00       	call   376f <unlink>
    1967:	83 c4 10             	add    $0x10,%esp
    196a:	eb bd                	jmp    1929 <linkunlink+0x75>
      link("cat", "x");
    196c:	83 ec 08             	sub    $0x8,%esp
    196f:	68 8d 44 00 00       	push   $0x448d
    1974:	68 11 42 00 00       	push   $0x4211
    1979:	e8 01 1e 00 00       	call   377f <link>
    197e:	83 c4 10             	add    $0x10,%esp
    1981:	eb a6                	jmp    1929 <linkunlink+0x75>
    }
  }

  if(pid)
    1983:	85 ff                	test   %edi,%edi
    1985:	74 1c                	je     19a3 <linkunlink+0xef>
    wait();
    1987:	e8 9b 1d 00 00       	call   3727 <wait>
  else
    exit();

  printf(1, "linkunlink ok\n");
    198c:	83 ec 08             	sub    $0x8,%esp
    198f:	68 15 42 00 00       	push   $0x4215
    1994:	6a 01                	push   $0x1
    1996:	e8 e9 1e 00 00       	call   3884 <printf>
}
    199b:	8d 65 f4             	lea    -0xc(%ebp),%esp
    199e:	5b                   	pop    %ebx
    199f:	5e                   	pop    %esi
    19a0:	5f                   	pop    %edi
    19a1:	5d                   	pop    %ebp
    19a2:	c3                   	ret    
    exit();
    19a3:	e8 77 1d 00 00       	call   371f <exit>

000019a8 <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    19a8:	55                   	push   %ebp
    19a9:	89 e5                	mov    %esp,%ebp
    19ab:	53                   	push   %ebx
    19ac:	83 ec 1c             	sub    $0x1c,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    19af:	68 24 42 00 00       	push   $0x4224
    19b4:	6a 01                	push   $0x1
    19b6:	e8 c9 1e 00 00       	call   3884 <printf>
  unlink("bd");
    19bb:	c7 04 24 31 42 00 00 	movl   $0x4231,(%esp)
    19c2:	e8 a8 1d 00 00       	call   376f <unlink>

  fd = open("bd", O_CREATE);
    19c7:	83 c4 08             	add    $0x8,%esp
    19ca:	68 00 02 00 00       	push   $0x200
    19cf:	68 31 42 00 00       	push   $0x4231
    19d4:	e8 86 1d 00 00       	call   375f <open>
  if(fd < 0){
    19d9:	83 c4 10             	add    $0x10,%esp
    19dc:	85 c0                	test   %eax,%eax
    19de:	78 65                	js     1a45 <bigdir+0x9d>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);
    19e0:	83 ec 0c             	sub    $0xc,%esp
    19e3:	50                   	push   %eax
    19e4:	e8 5e 1d 00 00       	call   3747 <close>

  for(i = 0; i < 500; i++){
    19e9:	83 c4 10             	add    $0x10,%esp
    19ec:	bb 00 00 00 00       	mov    $0x0,%ebx
    19f1:	81 fb f3 01 00 00    	cmp    $0x1f3,%ebx
    19f7:	7f 74                	jg     1a6d <bigdir+0xc5>
    name[0] = 'x';
    19f9:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    19fd:	8d 43 3f             	lea    0x3f(%ebx),%eax
    1a00:	85 db                	test   %ebx,%ebx
    1a02:	0f 49 c3             	cmovns %ebx,%eax
    1a05:	c1 f8 06             	sar    $0x6,%eax
    1a08:	83 c0 30             	add    $0x30,%eax
    1a0b:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1a0e:	89 da                	mov    %ebx,%edx
    1a10:	c1 fa 1f             	sar    $0x1f,%edx
    1a13:	c1 ea 1a             	shr    $0x1a,%edx
    1a16:	8d 04 13             	lea    (%ebx,%edx,1),%eax
    1a19:	83 e0 3f             	and    $0x3f,%eax
    1a1c:	29 d0                	sub    %edx,%eax
    1a1e:	83 c0 30             	add    $0x30,%eax
    1a21:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1a24:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(link("bd", name) != 0){
    1a28:	83 ec 08             	sub    $0x8,%esp
    1a2b:	8d 45 ee             	lea    -0x12(%ebp),%eax
    1a2e:	50                   	push   %eax
    1a2f:	68 31 42 00 00       	push   $0x4231
    1a34:	e8 46 1d 00 00       	call   377f <link>
    1a39:	83 c4 10             	add    $0x10,%esp
    1a3c:	85 c0                	test   %eax,%eax
    1a3e:	75 19                	jne    1a59 <bigdir+0xb1>
  for(i = 0; i < 500; i++){
    1a40:	83 c3 01             	add    $0x1,%ebx
    1a43:	eb ac                	jmp    19f1 <bigdir+0x49>
    printf(1, "bigdir create failed\n");
    1a45:	83 ec 08             	sub    $0x8,%esp
    1a48:	68 34 42 00 00       	push   $0x4234
    1a4d:	6a 01                	push   $0x1
    1a4f:	e8 30 1e 00 00       	call   3884 <printf>
    exit();
    1a54:	e8 c6 1c 00 00       	call   371f <exit>
      printf(1, "bigdir link failed\n");
    1a59:	83 ec 08             	sub    $0x8,%esp
    1a5c:	68 4a 42 00 00       	push   $0x424a
    1a61:	6a 01                	push   $0x1
    1a63:	e8 1c 1e 00 00       	call   3884 <printf>
      exit();
    1a68:	e8 b2 1c 00 00       	call   371f <exit>
    }
  }

  unlink("bd");
    1a6d:	83 ec 0c             	sub    $0xc,%esp
    1a70:	68 31 42 00 00       	push   $0x4231
    1a75:	e8 f5 1c 00 00       	call   376f <unlink>
  for(i = 0; i < 500; i++){
    1a7a:	83 c4 10             	add    $0x10,%esp
    1a7d:	bb 00 00 00 00       	mov    $0x0,%ebx
    1a82:	eb 03                	jmp    1a87 <bigdir+0xdf>
    1a84:	83 c3 01             	add    $0x1,%ebx
    1a87:	81 fb f3 01 00 00    	cmp    $0x1f3,%ebx
    1a8d:	7f 56                	jg     1ae5 <bigdir+0x13d>
    name[0] = 'x';
    1a8f:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    1a93:	8d 43 3f             	lea    0x3f(%ebx),%eax
    1a96:	85 db                	test   %ebx,%ebx
    1a98:	0f 49 c3             	cmovns %ebx,%eax
    1a9b:	c1 f8 06             	sar    $0x6,%eax
    1a9e:	83 c0 30             	add    $0x30,%eax
    1aa1:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1aa4:	89 da                	mov    %ebx,%edx
    1aa6:	c1 fa 1f             	sar    $0x1f,%edx
    1aa9:	c1 ea 1a             	shr    $0x1a,%edx
    1aac:	8d 04 13             	lea    (%ebx,%edx,1),%eax
    1aaf:	83 e0 3f             	and    $0x3f,%eax
    1ab2:	29 d0                	sub    %edx,%eax
    1ab4:	83 c0 30             	add    $0x30,%eax
    1ab7:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1aba:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(unlink(name) != 0){
    1abe:	83 ec 0c             	sub    $0xc,%esp
    1ac1:	8d 45 ee             	lea    -0x12(%ebp),%eax
    1ac4:	50                   	push   %eax
    1ac5:	e8 a5 1c 00 00       	call   376f <unlink>
    1aca:	83 c4 10             	add    $0x10,%esp
    1acd:	85 c0                	test   %eax,%eax
    1acf:	74 b3                	je     1a84 <bigdir+0xdc>
      printf(1, "bigdir unlink failed");
    1ad1:	83 ec 08             	sub    $0x8,%esp
    1ad4:	68 5e 42 00 00       	push   $0x425e
    1ad9:	6a 01                	push   $0x1
    1adb:	e8 a4 1d 00 00       	call   3884 <printf>
      exit();
    1ae0:	e8 3a 1c 00 00       	call   371f <exit>
    }
  }

  printf(1, "bigdir ok\n");
    1ae5:	83 ec 08             	sub    $0x8,%esp
    1ae8:	68 73 42 00 00       	push   $0x4273
    1aed:	6a 01                	push   $0x1
    1aef:	e8 90 1d 00 00       	call   3884 <printf>
}
    1af4:	83 c4 10             	add    $0x10,%esp
    1af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1afa:	c9                   	leave  
    1afb:	c3                   	ret    

00001afc <subdir>:

void
subdir(void)
{
    1afc:	55                   	push   %ebp
    1afd:	89 e5                	mov    %esp,%ebp
    1aff:	53                   	push   %ebx
    1b00:	83 ec 0c             	sub    $0xc,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1b03:	68 7e 42 00 00       	push   $0x427e
    1b08:	6a 01                	push   $0x1
    1b0a:	e8 75 1d 00 00       	call   3884 <printf>

  unlink("ff");
    1b0f:	c7 04 24 07 43 00 00 	movl   $0x4307,(%esp)
    1b16:	e8 54 1c 00 00       	call   376f <unlink>
  if(mkdir("dd") != 0){
    1b1b:	c7 04 24 a4 43 00 00 	movl   $0x43a4,(%esp)
    1b22:	e8 60 1c 00 00       	call   3787 <mkdir>
    1b27:	83 c4 10             	add    $0x10,%esp
    1b2a:	85 c0                	test   %eax,%eax
    1b2c:	0f 85 14 04 00 00    	jne    1f46 <subdir+0x44a>
    printf(1, "subdir mkdir dd failed\n");
    exit();
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1b32:	83 ec 08             	sub    $0x8,%esp
    1b35:	68 02 02 00 00       	push   $0x202
    1b3a:	68 dd 42 00 00       	push   $0x42dd
    1b3f:	e8 1b 1c 00 00       	call   375f <open>
    1b44:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1b46:	83 c4 10             	add    $0x10,%esp
    1b49:	85 c0                	test   %eax,%eax
    1b4b:	0f 88 09 04 00 00    	js     1f5a <subdir+0x45e>
    printf(1, "create dd/ff failed\n");
    exit();
  }
  write(fd, "ff", 2);
    1b51:	83 ec 04             	sub    $0x4,%esp
    1b54:	6a 02                	push   $0x2
    1b56:	68 07 43 00 00       	push   $0x4307
    1b5b:	50                   	push   %eax
    1b5c:	e8 de 1b 00 00       	call   373f <write>
  close(fd);
    1b61:	89 1c 24             	mov    %ebx,(%esp)
    1b64:	e8 de 1b 00 00       	call   3747 <close>

  if(unlink("dd") >= 0){
    1b69:	c7 04 24 a4 43 00 00 	movl   $0x43a4,(%esp)
    1b70:	e8 fa 1b 00 00       	call   376f <unlink>
    1b75:	83 c4 10             	add    $0x10,%esp
    1b78:	85 c0                	test   %eax,%eax
    1b7a:	0f 89 ee 03 00 00    	jns    1f6e <subdir+0x472>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    exit();
  }

  if(mkdir("/dd/dd") != 0){
    1b80:	83 ec 0c             	sub    $0xc,%esp
    1b83:	68 b8 42 00 00       	push   $0x42b8
    1b88:	e8 fa 1b 00 00       	call   3787 <mkdir>
    1b8d:	83 c4 10             	add    $0x10,%esp
    1b90:	85 c0                	test   %eax,%eax
    1b92:	0f 85 ea 03 00 00    	jne    1f82 <subdir+0x486>
    printf(1, "subdir mkdir dd/dd failed\n");
    exit();
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    1b98:	83 ec 08             	sub    $0x8,%esp
    1b9b:	68 02 02 00 00       	push   $0x202
    1ba0:	68 da 42 00 00       	push   $0x42da
    1ba5:	e8 b5 1b 00 00       	call   375f <open>
    1baa:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1bac:	83 c4 10             	add    $0x10,%esp
    1baf:	85 c0                	test   %eax,%eax
    1bb1:	0f 88 df 03 00 00    	js     1f96 <subdir+0x49a>
    printf(1, "create dd/dd/ff failed\n");
    exit();
  }
  write(fd, "FF", 2);
    1bb7:	83 ec 04             	sub    $0x4,%esp
    1bba:	6a 02                	push   $0x2
    1bbc:	68 fb 42 00 00       	push   $0x42fb
    1bc1:	50                   	push   %eax
    1bc2:	e8 78 1b 00 00       	call   373f <write>
  close(fd);
    1bc7:	89 1c 24             	mov    %ebx,(%esp)
    1bca:	e8 78 1b 00 00       	call   3747 <close>

  fd = open("dd/dd/../ff", 0);
    1bcf:	83 c4 08             	add    $0x8,%esp
    1bd2:	6a 00                	push   $0x0
    1bd4:	68 fe 42 00 00       	push   $0x42fe
    1bd9:	e8 81 1b 00 00       	call   375f <open>
    1bde:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1be0:	83 c4 10             	add    $0x10,%esp
    1be3:	85 c0                	test   %eax,%eax
    1be5:	0f 88 bf 03 00 00    	js     1faa <subdir+0x4ae>
    printf(1, "open dd/dd/../ff failed\n");
    exit();
  }
  cc = read(fd, buf, sizeof(buf));
    1beb:	83 ec 04             	sub    $0x4,%esp
    1bee:	68 00 20 00 00       	push   $0x2000
    1bf3:	68 80 7a 00 00       	push   $0x7a80
    1bf8:	50                   	push   %eax
    1bf9:	e8 39 1b 00 00       	call   3737 <read>
  if(cc != 2 || buf[0] != 'f'){
    1bfe:	83 c4 10             	add    $0x10,%esp
    1c01:	83 f8 02             	cmp    $0x2,%eax
    1c04:	0f 85 b4 03 00 00    	jne    1fbe <subdir+0x4c2>
    1c0a:	80 3d 80 7a 00 00 66 	cmpb   $0x66,0x7a80
    1c11:	0f 85 a7 03 00 00    	jne    1fbe <subdir+0x4c2>
    printf(1, "dd/dd/../ff wrong content\n");
    exit();
  }
  close(fd);
    1c17:	83 ec 0c             	sub    $0xc,%esp
    1c1a:	53                   	push   %ebx
    1c1b:	e8 27 1b 00 00       	call   3747 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    1c20:	83 c4 08             	add    $0x8,%esp
    1c23:	68 3e 43 00 00       	push   $0x433e
    1c28:	68 da 42 00 00       	push   $0x42da
    1c2d:	e8 4d 1b 00 00       	call   377f <link>
    1c32:	83 c4 10             	add    $0x10,%esp
    1c35:	85 c0                	test   %eax,%eax
    1c37:	0f 85 95 03 00 00    	jne    1fd2 <subdir+0x4d6>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    exit();
  }

  if(unlink("dd/dd/ff") != 0){
    1c3d:	83 ec 0c             	sub    $0xc,%esp
    1c40:	68 da 42 00 00       	push   $0x42da
    1c45:	e8 25 1b 00 00       	call   376f <unlink>
    1c4a:	83 c4 10             	add    $0x10,%esp
    1c4d:	85 c0                	test   %eax,%eax
    1c4f:	0f 85 91 03 00 00    	jne    1fe6 <subdir+0x4ea>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1c55:	83 ec 08             	sub    $0x8,%esp
    1c58:	6a 00                	push   $0x0
    1c5a:	68 da 42 00 00       	push   $0x42da
    1c5f:	e8 fb 1a 00 00       	call   375f <open>
    1c64:	83 c4 10             	add    $0x10,%esp
    1c67:	85 c0                	test   %eax,%eax
    1c69:	0f 89 8b 03 00 00    	jns    1ffa <subdir+0x4fe>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    exit();
  }

  if(chdir("dd") != 0){
    1c6f:	83 ec 0c             	sub    $0xc,%esp
    1c72:	68 a4 43 00 00       	push   $0x43a4
    1c77:	e8 13 1b 00 00       	call   378f <chdir>
    1c7c:	83 c4 10             	add    $0x10,%esp
    1c7f:	85 c0                	test   %eax,%eax
    1c81:	0f 85 87 03 00 00    	jne    200e <subdir+0x512>
    printf(1, "chdir dd failed\n");
    exit();
  }
  if(chdir("dd/../../dd") != 0){
    1c87:	83 ec 0c             	sub    $0xc,%esp
    1c8a:	68 72 43 00 00       	push   $0x4372
    1c8f:	e8 fb 1a 00 00       	call   378f <chdir>
    1c94:	83 c4 10             	add    $0x10,%esp
    1c97:	85 c0                	test   %eax,%eax
    1c99:	0f 85 83 03 00 00    	jne    2022 <subdir+0x526>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("dd/../../../dd") != 0){
    1c9f:	83 ec 0c             	sub    $0xc,%esp
    1ca2:	68 98 43 00 00       	push   $0x4398
    1ca7:	e8 e3 1a 00 00       	call   378f <chdir>
    1cac:	83 c4 10             	add    $0x10,%esp
    1caf:	85 c0                	test   %eax,%eax
    1cb1:	0f 85 7f 03 00 00    	jne    2036 <subdir+0x53a>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("./..") != 0){
    1cb7:	83 ec 0c             	sub    $0xc,%esp
    1cba:	68 a7 43 00 00       	push   $0x43a7
    1cbf:	e8 cb 1a 00 00       	call   378f <chdir>
    1cc4:	83 c4 10             	add    $0x10,%esp
    1cc7:	85 c0                	test   %eax,%eax
    1cc9:	0f 85 7b 03 00 00    	jne    204a <subdir+0x54e>
    printf(1, "chdir ./.. failed\n");
    exit();
  }

  fd = open("dd/dd/ffff", 0);
    1ccf:	83 ec 08             	sub    $0x8,%esp
    1cd2:	6a 00                	push   $0x0
    1cd4:	68 3e 43 00 00       	push   $0x433e
    1cd9:	e8 81 1a 00 00       	call   375f <open>
    1cde:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1ce0:	83 c4 10             	add    $0x10,%esp
    1ce3:	85 c0                	test   %eax,%eax
    1ce5:	0f 88 73 03 00 00    	js     205e <subdir+0x562>
    printf(1, "open dd/dd/ffff failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    1ceb:	83 ec 04             	sub    $0x4,%esp
    1cee:	68 00 20 00 00       	push   $0x2000
    1cf3:	68 80 7a 00 00       	push   $0x7a80
    1cf8:	50                   	push   %eax
    1cf9:	e8 39 1a 00 00       	call   3737 <read>
    1cfe:	83 c4 10             	add    $0x10,%esp
    1d01:	83 f8 02             	cmp    $0x2,%eax
    1d04:	0f 85 68 03 00 00    	jne    2072 <subdir+0x576>
    printf(1, "read dd/dd/ffff wrong len\n");
    exit();
  }
  close(fd);
    1d0a:	83 ec 0c             	sub    $0xc,%esp
    1d0d:	53                   	push   %ebx
    1d0e:	e8 34 1a 00 00       	call   3747 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1d13:	83 c4 08             	add    $0x8,%esp
    1d16:	6a 00                	push   $0x0
    1d18:	68 da 42 00 00       	push   $0x42da
    1d1d:	e8 3d 1a 00 00       	call   375f <open>
    1d22:	83 c4 10             	add    $0x10,%esp
    1d25:	85 c0                	test   %eax,%eax
    1d27:	0f 89 59 03 00 00    	jns    2086 <subdir+0x58a>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    exit();
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    1d2d:	83 ec 08             	sub    $0x8,%esp
    1d30:	68 02 02 00 00       	push   $0x202
    1d35:	68 f2 43 00 00       	push   $0x43f2
    1d3a:	e8 20 1a 00 00       	call   375f <open>
    1d3f:	83 c4 10             	add    $0x10,%esp
    1d42:	85 c0                	test   %eax,%eax
    1d44:	0f 89 50 03 00 00    	jns    209a <subdir+0x59e>
    printf(1, "create dd/ff/ff succeeded!\n");
    exit();
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    1d4a:	83 ec 08             	sub    $0x8,%esp
    1d4d:	68 02 02 00 00       	push   $0x202
    1d52:	68 17 44 00 00       	push   $0x4417
    1d57:	e8 03 1a 00 00       	call   375f <open>
    1d5c:	83 c4 10             	add    $0x10,%esp
    1d5f:	85 c0                	test   %eax,%eax
    1d61:	0f 89 47 03 00 00    	jns    20ae <subdir+0x5b2>
    printf(1, "create dd/xx/ff succeeded!\n");
    exit();
  }
  if(open("dd", O_CREATE) >= 0){
    1d67:	83 ec 08             	sub    $0x8,%esp
    1d6a:	68 00 02 00 00       	push   $0x200
    1d6f:	68 a4 43 00 00       	push   $0x43a4
    1d74:	e8 e6 19 00 00       	call   375f <open>
    1d79:	83 c4 10             	add    $0x10,%esp
    1d7c:	85 c0                	test   %eax,%eax
    1d7e:	0f 89 3e 03 00 00    	jns    20c2 <subdir+0x5c6>
    printf(1, "create dd succeeded!\n");
    exit();
  }
  if(open("dd", O_RDWR) >= 0){
    1d84:	83 ec 08             	sub    $0x8,%esp
    1d87:	6a 02                	push   $0x2
    1d89:	68 a4 43 00 00       	push   $0x43a4
    1d8e:	e8 cc 19 00 00       	call   375f <open>
    1d93:	83 c4 10             	add    $0x10,%esp
    1d96:	85 c0                	test   %eax,%eax
    1d98:	0f 89 38 03 00 00    	jns    20d6 <subdir+0x5da>
    printf(1, "open dd rdwr succeeded!\n");
    exit();
  }
  if(open("dd", O_WRONLY) >= 0){
    1d9e:	83 ec 08             	sub    $0x8,%esp
    1da1:	6a 01                	push   $0x1
    1da3:	68 a4 43 00 00       	push   $0x43a4
    1da8:	e8 b2 19 00 00       	call   375f <open>
    1dad:	83 c4 10             	add    $0x10,%esp
    1db0:	85 c0                	test   %eax,%eax
    1db2:	0f 89 32 03 00 00    	jns    20ea <subdir+0x5ee>
    printf(1, "open dd wronly succeeded!\n");
    exit();
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    1db8:	83 ec 08             	sub    $0x8,%esp
    1dbb:	68 86 44 00 00       	push   $0x4486
    1dc0:	68 f2 43 00 00       	push   $0x43f2
    1dc5:	e8 b5 19 00 00       	call   377f <link>
    1dca:	83 c4 10             	add    $0x10,%esp
    1dcd:	85 c0                	test   %eax,%eax
    1dcf:	0f 84 29 03 00 00    	je     20fe <subdir+0x602>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    1dd5:	83 ec 08             	sub    $0x8,%esp
    1dd8:	68 86 44 00 00       	push   $0x4486
    1ddd:	68 17 44 00 00       	push   $0x4417
    1de2:	e8 98 19 00 00       	call   377f <link>
    1de7:	83 c4 10             	add    $0x10,%esp
    1dea:	85 c0                	test   %eax,%eax
    1dec:	0f 84 20 03 00 00    	je     2112 <subdir+0x616>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    1df2:	83 ec 08             	sub    $0x8,%esp
    1df5:	68 3e 43 00 00       	push   $0x433e
    1dfa:	68 dd 42 00 00       	push   $0x42dd
    1dff:	e8 7b 19 00 00       	call   377f <link>
    1e04:	83 c4 10             	add    $0x10,%esp
    1e07:	85 c0                	test   %eax,%eax
    1e09:	0f 84 17 03 00 00    	je     2126 <subdir+0x62a>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    exit();
  }
  if(mkdir("dd/ff/ff") == 0){
    1e0f:	83 ec 0c             	sub    $0xc,%esp
    1e12:	68 f2 43 00 00       	push   $0x43f2
    1e17:	e8 6b 19 00 00       	call   3787 <mkdir>
    1e1c:	83 c4 10             	add    $0x10,%esp
    1e1f:	85 c0                	test   %eax,%eax
    1e21:	0f 84 13 03 00 00    	je     213a <subdir+0x63e>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/xx/ff") == 0){
    1e27:	83 ec 0c             	sub    $0xc,%esp
    1e2a:	68 17 44 00 00       	push   $0x4417
    1e2f:	e8 53 19 00 00       	call   3787 <mkdir>
    1e34:	83 c4 10             	add    $0x10,%esp
    1e37:	85 c0                	test   %eax,%eax
    1e39:	0f 84 0f 03 00 00    	je     214e <subdir+0x652>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/dd/ffff") == 0){
    1e3f:	83 ec 0c             	sub    $0xc,%esp
    1e42:	68 3e 43 00 00       	push   $0x433e
    1e47:	e8 3b 19 00 00       	call   3787 <mkdir>
    1e4c:	83 c4 10             	add    $0x10,%esp
    1e4f:	85 c0                	test   %eax,%eax
    1e51:	0f 84 0b 03 00 00    	je     2162 <subdir+0x666>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    exit();
  }
  if(unlink("dd/xx/ff") == 0){
    1e57:	83 ec 0c             	sub    $0xc,%esp
    1e5a:	68 17 44 00 00       	push   $0x4417
    1e5f:	e8 0b 19 00 00       	call   376f <unlink>
    1e64:	83 c4 10             	add    $0x10,%esp
    1e67:	85 c0                	test   %eax,%eax
    1e69:	0f 84 07 03 00 00    	je     2176 <subdir+0x67a>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    exit();
  }
  if(unlink("dd/ff/ff") == 0){
    1e6f:	83 ec 0c             	sub    $0xc,%esp
    1e72:	68 f2 43 00 00       	push   $0x43f2
    1e77:	e8 f3 18 00 00       	call   376f <unlink>
    1e7c:	83 c4 10             	add    $0x10,%esp
    1e7f:	85 c0                	test   %eax,%eax
    1e81:	0f 84 03 03 00 00    	je     218a <subdir+0x68e>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/ff") == 0){
    1e87:	83 ec 0c             	sub    $0xc,%esp
    1e8a:	68 dd 42 00 00       	push   $0x42dd
    1e8f:	e8 fb 18 00 00       	call   378f <chdir>
    1e94:	83 c4 10             	add    $0x10,%esp
    1e97:	85 c0                	test   %eax,%eax
    1e99:	0f 84 ff 02 00 00    	je     219e <subdir+0x6a2>
    printf(1, "chdir dd/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/xx") == 0){
    1e9f:	83 ec 0c             	sub    $0xc,%esp
    1ea2:	68 89 44 00 00       	push   $0x4489
    1ea7:	e8 e3 18 00 00       	call   378f <chdir>
    1eac:	83 c4 10             	add    $0x10,%esp
    1eaf:	85 c0                	test   %eax,%eax
    1eb1:	0f 84 fb 02 00 00    	je     21b2 <subdir+0x6b6>
    printf(1, "chdir dd/xx succeeded!\n");
    exit();
  }

  if(unlink("dd/dd/ffff") != 0){
    1eb7:	83 ec 0c             	sub    $0xc,%esp
    1eba:	68 3e 43 00 00       	push   $0x433e
    1ebf:	e8 ab 18 00 00       	call   376f <unlink>
    1ec4:	83 c4 10             	add    $0x10,%esp
    1ec7:	85 c0                	test   %eax,%eax
    1ec9:	0f 85 f7 02 00 00    	jne    21c6 <subdir+0x6ca>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(unlink("dd/ff") != 0){
    1ecf:	83 ec 0c             	sub    $0xc,%esp
    1ed2:	68 dd 42 00 00       	push   $0x42dd
    1ed7:	e8 93 18 00 00       	call   376f <unlink>
    1edc:	83 c4 10             	add    $0x10,%esp
    1edf:	85 c0                	test   %eax,%eax
    1ee1:	0f 85 f3 02 00 00    	jne    21da <subdir+0x6de>
    printf(1, "unlink dd/ff failed\n");
    exit();
  }
  if(unlink("dd") == 0){
    1ee7:	83 ec 0c             	sub    $0xc,%esp
    1eea:	68 a4 43 00 00       	push   $0x43a4
    1eef:	e8 7b 18 00 00       	call   376f <unlink>
    1ef4:	83 c4 10             	add    $0x10,%esp
    1ef7:	85 c0                	test   %eax,%eax
    1ef9:	0f 84 ef 02 00 00    	je     21ee <subdir+0x6f2>
    printf(1, "unlink non-empty dd succeeded!\n");
    exit();
  }
  if(unlink("dd/dd") < 0){
    1eff:	83 ec 0c             	sub    $0xc,%esp
    1f02:	68 b9 42 00 00       	push   $0x42b9
    1f07:	e8 63 18 00 00       	call   376f <unlink>
    1f0c:	83 c4 10             	add    $0x10,%esp
    1f0f:	85 c0                	test   %eax,%eax
    1f11:	0f 88 eb 02 00 00    	js     2202 <subdir+0x706>
    printf(1, "unlink dd/dd failed\n");
    exit();
  }
  if(unlink("dd") < 0){
    1f17:	83 ec 0c             	sub    $0xc,%esp
    1f1a:	68 a4 43 00 00       	push   $0x43a4
    1f1f:	e8 4b 18 00 00       	call   376f <unlink>
    1f24:	83 c4 10             	add    $0x10,%esp
    1f27:	85 c0                	test   %eax,%eax
    1f29:	0f 88 e7 02 00 00    	js     2216 <subdir+0x71a>
    printf(1, "unlink dd failed\n");
    exit();
  }

  printf(1, "subdir ok\n");
    1f2f:	83 ec 08             	sub    $0x8,%esp
    1f32:	68 86 45 00 00       	push   $0x4586
    1f37:	6a 01                	push   $0x1
    1f39:	e8 46 19 00 00       	call   3884 <printf>
}
    1f3e:	83 c4 10             	add    $0x10,%esp
    1f41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1f44:	c9                   	leave  
    1f45:	c3                   	ret    
    printf(1, "subdir mkdir dd failed\n");
    1f46:	83 ec 08             	sub    $0x8,%esp
    1f49:	68 8b 42 00 00       	push   $0x428b
    1f4e:	6a 01                	push   $0x1
    1f50:	e8 2f 19 00 00       	call   3884 <printf>
    exit();
    1f55:	e8 c5 17 00 00       	call   371f <exit>
    printf(1, "create dd/ff failed\n");
    1f5a:	83 ec 08             	sub    $0x8,%esp
    1f5d:	68 a3 42 00 00       	push   $0x42a3
    1f62:	6a 01                	push   $0x1
    1f64:	e8 1b 19 00 00       	call   3884 <printf>
    exit();
    1f69:	e8 b1 17 00 00       	call   371f <exit>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    1f6e:	83 ec 08             	sub    $0x8,%esp
    1f71:	68 70 4d 00 00       	push   $0x4d70
    1f76:	6a 01                	push   $0x1
    1f78:	e8 07 19 00 00       	call   3884 <printf>
    exit();
    1f7d:	e8 9d 17 00 00       	call   371f <exit>
    printf(1, "subdir mkdir dd/dd failed\n");
    1f82:	83 ec 08             	sub    $0x8,%esp
    1f85:	68 bf 42 00 00       	push   $0x42bf
    1f8a:	6a 01                	push   $0x1
    1f8c:	e8 f3 18 00 00       	call   3884 <printf>
    exit();
    1f91:	e8 89 17 00 00       	call   371f <exit>
    printf(1, "create dd/dd/ff failed\n");
    1f96:	83 ec 08             	sub    $0x8,%esp
    1f99:	68 e3 42 00 00       	push   $0x42e3
    1f9e:	6a 01                	push   $0x1
    1fa0:	e8 df 18 00 00       	call   3884 <printf>
    exit();
    1fa5:	e8 75 17 00 00       	call   371f <exit>
    printf(1, "open dd/dd/../ff failed\n");
    1faa:	83 ec 08             	sub    $0x8,%esp
    1fad:	68 0a 43 00 00       	push   $0x430a
    1fb2:	6a 01                	push   $0x1
    1fb4:	e8 cb 18 00 00       	call   3884 <printf>
    exit();
    1fb9:	e8 61 17 00 00       	call   371f <exit>
    printf(1, "dd/dd/../ff wrong content\n");
    1fbe:	83 ec 08             	sub    $0x8,%esp
    1fc1:	68 23 43 00 00       	push   $0x4323
    1fc6:	6a 01                	push   $0x1
    1fc8:	e8 b7 18 00 00       	call   3884 <printf>
    exit();
    1fcd:	e8 4d 17 00 00       	call   371f <exit>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    1fd2:	83 ec 08             	sub    $0x8,%esp
    1fd5:	68 98 4d 00 00       	push   $0x4d98
    1fda:	6a 01                	push   $0x1
    1fdc:	e8 a3 18 00 00       	call   3884 <printf>
    exit();
    1fe1:	e8 39 17 00 00       	call   371f <exit>
    printf(1, "unlink dd/dd/ff failed\n");
    1fe6:	83 ec 08             	sub    $0x8,%esp
    1fe9:	68 49 43 00 00       	push   $0x4349
    1fee:	6a 01                	push   $0x1
    1ff0:	e8 8f 18 00 00       	call   3884 <printf>
    exit();
    1ff5:	e8 25 17 00 00       	call   371f <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    1ffa:	83 ec 08             	sub    $0x8,%esp
    1ffd:	68 bc 4d 00 00       	push   $0x4dbc
    2002:	6a 01                	push   $0x1
    2004:	e8 7b 18 00 00       	call   3884 <printf>
    exit();
    2009:	e8 11 17 00 00       	call   371f <exit>
    printf(1, "chdir dd failed\n");
    200e:	83 ec 08             	sub    $0x8,%esp
    2011:	68 61 43 00 00       	push   $0x4361
    2016:	6a 01                	push   $0x1
    2018:	e8 67 18 00 00       	call   3884 <printf>
    exit();
    201d:	e8 fd 16 00 00       	call   371f <exit>
    printf(1, "chdir dd/../../dd failed\n");
    2022:	83 ec 08             	sub    $0x8,%esp
    2025:	68 7e 43 00 00       	push   $0x437e
    202a:	6a 01                	push   $0x1
    202c:	e8 53 18 00 00       	call   3884 <printf>
    exit();
    2031:	e8 e9 16 00 00       	call   371f <exit>
    printf(1, "chdir dd/../../dd failed\n");
    2036:	83 ec 08             	sub    $0x8,%esp
    2039:	68 7e 43 00 00       	push   $0x437e
    203e:	6a 01                	push   $0x1
    2040:	e8 3f 18 00 00       	call   3884 <printf>
    exit();
    2045:	e8 d5 16 00 00       	call   371f <exit>
    printf(1, "chdir ./.. failed\n");
    204a:	83 ec 08             	sub    $0x8,%esp
    204d:	68 ac 43 00 00       	push   $0x43ac
    2052:	6a 01                	push   $0x1
    2054:	e8 2b 18 00 00       	call   3884 <printf>
    exit();
    2059:	e8 c1 16 00 00       	call   371f <exit>
    printf(1, "open dd/dd/ffff failed\n");
    205e:	83 ec 08             	sub    $0x8,%esp
    2061:	68 bf 43 00 00       	push   $0x43bf
    2066:	6a 01                	push   $0x1
    2068:	e8 17 18 00 00       	call   3884 <printf>
    exit();
    206d:	e8 ad 16 00 00       	call   371f <exit>
    printf(1, "read dd/dd/ffff wrong len\n");
    2072:	83 ec 08             	sub    $0x8,%esp
    2075:	68 d7 43 00 00       	push   $0x43d7
    207a:	6a 01                	push   $0x1
    207c:	e8 03 18 00 00       	call   3884 <printf>
    exit();
    2081:	e8 99 16 00 00       	call   371f <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    2086:	83 ec 08             	sub    $0x8,%esp
    2089:	68 e0 4d 00 00       	push   $0x4de0
    208e:	6a 01                	push   $0x1
    2090:	e8 ef 17 00 00       	call   3884 <printf>
    exit();
    2095:	e8 85 16 00 00       	call   371f <exit>
    printf(1, "create dd/ff/ff succeeded!\n");
    209a:	83 ec 08             	sub    $0x8,%esp
    209d:	68 fb 43 00 00       	push   $0x43fb
    20a2:	6a 01                	push   $0x1
    20a4:	e8 db 17 00 00       	call   3884 <printf>
    exit();
    20a9:	e8 71 16 00 00       	call   371f <exit>
    printf(1, "create dd/xx/ff succeeded!\n");
    20ae:	83 ec 08             	sub    $0x8,%esp
    20b1:	68 20 44 00 00       	push   $0x4420
    20b6:	6a 01                	push   $0x1
    20b8:	e8 c7 17 00 00       	call   3884 <printf>
    exit();
    20bd:	e8 5d 16 00 00       	call   371f <exit>
    printf(1, "create dd succeeded!\n");
    20c2:	83 ec 08             	sub    $0x8,%esp
    20c5:	68 3c 44 00 00       	push   $0x443c
    20ca:	6a 01                	push   $0x1
    20cc:	e8 b3 17 00 00       	call   3884 <printf>
    exit();
    20d1:	e8 49 16 00 00       	call   371f <exit>
    printf(1, "open dd rdwr succeeded!\n");
    20d6:	83 ec 08             	sub    $0x8,%esp
    20d9:	68 52 44 00 00       	push   $0x4452
    20de:	6a 01                	push   $0x1
    20e0:	e8 9f 17 00 00       	call   3884 <printf>
    exit();
    20e5:	e8 35 16 00 00       	call   371f <exit>
    printf(1, "open dd wronly succeeded!\n");
    20ea:	83 ec 08             	sub    $0x8,%esp
    20ed:	68 6b 44 00 00       	push   $0x446b
    20f2:	6a 01                	push   $0x1
    20f4:	e8 8b 17 00 00       	call   3884 <printf>
    exit();
    20f9:	e8 21 16 00 00       	call   371f <exit>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    20fe:	83 ec 08             	sub    $0x8,%esp
    2101:	68 08 4e 00 00       	push   $0x4e08
    2106:	6a 01                	push   $0x1
    2108:	e8 77 17 00 00       	call   3884 <printf>
    exit();
    210d:	e8 0d 16 00 00       	call   371f <exit>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    2112:	83 ec 08             	sub    $0x8,%esp
    2115:	68 2c 4e 00 00       	push   $0x4e2c
    211a:	6a 01                	push   $0x1
    211c:	e8 63 17 00 00       	call   3884 <printf>
    exit();
    2121:	e8 f9 15 00 00       	call   371f <exit>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2126:	83 ec 08             	sub    $0x8,%esp
    2129:	68 50 4e 00 00       	push   $0x4e50
    212e:	6a 01                	push   $0x1
    2130:	e8 4f 17 00 00       	call   3884 <printf>
    exit();
    2135:	e8 e5 15 00 00       	call   371f <exit>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    213a:	83 ec 08             	sub    $0x8,%esp
    213d:	68 8f 44 00 00       	push   $0x448f
    2142:	6a 01                	push   $0x1
    2144:	e8 3b 17 00 00       	call   3884 <printf>
    exit();
    2149:	e8 d1 15 00 00       	call   371f <exit>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    214e:	83 ec 08             	sub    $0x8,%esp
    2151:	68 aa 44 00 00       	push   $0x44aa
    2156:	6a 01                	push   $0x1
    2158:	e8 27 17 00 00       	call   3884 <printf>
    exit();
    215d:	e8 bd 15 00 00       	call   371f <exit>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    2162:	83 ec 08             	sub    $0x8,%esp
    2165:	68 c5 44 00 00       	push   $0x44c5
    216a:	6a 01                	push   $0x1
    216c:	e8 13 17 00 00       	call   3884 <printf>
    exit();
    2171:	e8 a9 15 00 00       	call   371f <exit>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    2176:	83 ec 08             	sub    $0x8,%esp
    2179:	68 e2 44 00 00       	push   $0x44e2
    217e:	6a 01                	push   $0x1
    2180:	e8 ff 16 00 00       	call   3884 <printf>
    exit();
    2185:	e8 95 15 00 00       	call   371f <exit>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    218a:	83 ec 08             	sub    $0x8,%esp
    218d:	68 fe 44 00 00       	push   $0x44fe
    2192:	6a 01                	push   $0x1
    2194:	e8 eb 16 00 00       	call   3884 <printf>
    exit();
    2199:	e8 81 15 00 00       	call   371f <exit>
    printf(1, "chdir dd/ff succeeded!\n");
    219e:	83 ec 08             	sub    $0x8,%esp
    21a1:	68 1a 45 00 00       	push   $0x451a
    21a6:	6a 01                	push   $0x1
    21a8:	e8 d7 16 00 00       	call   3884 <printf>
    exit();
    21ad:	e8 6d 15 00 00       	call   371f <exit>
    printf(1, "chdir dd/xx succeeded!\n");
    21b2:	83 ec 08             	sub    $0x8,%esp
    21b5:	68 32 45 00 00       	push   $0x4532
    21ba:	6a 01                	push   $0x1
    21bc:	e8 c3 16 00 00       	call   3884 <printf>
    exit();
    21c1:	e8 59 15 00 00       	call   371f <exit>
    printf(1, "unlink dd/dd/ff failed\n");
    21c6:	83 ec 08             	sub    $0x8,%esp
    21c9:	68 49 43 00 00       	push   $0x4349
    21ce:	6a 01                	push   $0x1
    21d0:	e8 af 16 00 00       	call   3884 <printf>
    exit();
    21d5:	e8 45 15 00 00       	call   371f <exit>
    printf(1, "unlink dd/ff failed\n");
    21da:	83 ec 08             	sub    $0x8,%esp
    21dd:	68 4a 45 00 00       	push   $0x454a
    21e2:	6a 01                	push   $0x1
    21e4:	e8 9b 16 00 00       	call   3884 <printf>
    exit();
    21e9:	e8 31 15 00 00       	call   371f <exit>
    printf(1, "unlink non-empty dd succeeded!\n");
    21ee:	83 ec 08             	sub    $0x8,%esp
    21f1:	68 74 4e 00 00       	push   $0x4e74
    21f6:	6a 01                	push   $0x1
    21f8:	e8 87 16 00 00       	call   3884 <printf>
    exit();
    21fd:	e8 1d 15 00 00       	call   371f <exit>
    printf(1, "unlink dd/dd failed\n");
    2202:	83 ec 08             	sub    $0x8,%esp
    2205:	68 5f 45 00 00       	push   $0x455f
    220a:	6a 01                	push   $0x1
    220c:	e8 73 16 00 00       	call   3884 <printf>
    exit();
    2211:	e8 09 15 00 00       	call   371f <exit>
    printf(1, "unlink dd failed\n");
    2216:	83 ec 08             	sub    $0x8,%esp
    2219:	68 74 45 00 00       	push   $0x4574
    221e:	6a 01                	push   $0x1
    2220:	e8 5f 16 00 00       	call   3884 <printf>
    exit();
    2225:	e8 f5 14 00 00       	call   371f <exit>

0000222a <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    222a:	55                   	push   %ebp
    222b:	89 e5                	mov    %esp,%ebp
    222d:	57                   	push   %edi
    222e:	56                   	push   %esi
    222f:	53                   	push   %ebx
    2230:	83 ec 14             	sub    $0x14,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    2233:	68 91 45 00 00       	push   $0x4591
    2238:	6a 01                	push   $0x1
    223a:	e8 45 16 00 00       	call   3884 <printf>

  unlink("bigwrite");
    223f:	c7 04 24 a0 45 00 00 	movl   $0x45a0,(%esp)
    2246:	e8 24 15 00 00       	call   376f <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    224b:	83 c4 10             	add    $0x10,%esp
    224e:	be f3 01 00 00       	mov    $0x1f3,%esi
    2253:	eb 45                	jmp    229a <bigwrite+0x70>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
    2255:	83 ec 08             	sub    $0x8,%esp
    2258:	68 a9 45 00 00       	push   $0x45a9
    225d:	6a 01                	push   $0x1
    225f:	e8 20 16 00 00       	call   3884 <printf>
      exit();
    2264:	e8 b6 14 00 00       	call   371f <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
    2269:	50                   	push   %eax
    226a:	56                   	push   %esi
    226b:	68 c1 45 00 00       	push   $0x45c1
    2270:	6a 01                	push   $0x1
    2272:	e8 0d 16 00 00       	call   3884 <printf>
        exit();
    2277:	e8 a3 14 00 00       	call   371f <exit>
      }
    }
    close(fd);
    227c:	83 ec 0c             	sub    $0xc,%esp
    227f:	57                   	push   %edi
    2280:	e8 c2 14 00 00       	call   3747 <close>
    unlink("bigwrite");
    2285:	c7 04 24 a0 45 00 00 	movl   $0x45a0,(%esp)
    228c:	e8 de 14 00 00       	call   376f <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2291:	81 c6 d7 01 00 00    	add    $0x1d7,%esi
    2297:	83 c4 10             	add    $0x10,%esp
    229a:	81 fe ff 17 00 00    	cmp    $0x17ff,%esi
    22a0:	7f 40                	jg     22e2 <bigwrite+0xb8>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    22a2:	83 ec 08             	sub    $0x8,%esp
    22a5:	68 02 02 00 00       	push   $0x202
    22aa:	68 a0 45 00 00       	push   $0x45a0
    22af:	e8 ab 14 00 00       	call   375f <open>
    22b4:	89 c7                	mov    %eax,%edi
    if(fd < 0){
    22b6:	83 c4 10             	add    $0x10,%esp
    22b9:	85 c0                	test   %eax,%eax
    22bb:	78 98                	js     2255 <bigwrite+0x2b>
    for(i = 0; i < 2; i++){
    22bd:	bb 00 00 00 00       	mov    $0x0,%ebx
    22c2:	83 fb 01             	cmp    $0x1,%ebx
    22c5:	7f b5                	jg     227c <bigwrite+0x52>
      int cc = write(fd, buf, sz);
    22c7:	83 ec 04             	sub    $0x4,%esp
    22ca:	56                   	push   %esi
    22cb:	68 80 7a 00 00       	push   $0x7a80
    22d0:	57                   	push   %edi
    22d1:	e8 69 14 00 00       	call   373f <write>
      if(cc != sz){
    22d6:	83 c4 10             	add    $0x10,%esp
    22d9:	39 c6                	cmp    %eax,%esi
    22db:	75 8c                	jne    2269 <bigwrite+0x3f>
    for(i = 0; i < 2; i++){
    22dd:	83 c3 01             	add    $0x1,%ebx
    22e0:	eb e0                	jmp    22c2 <bigwrite+0x98>
  }

  printf(1, "bigwrite ok\n");
    22e2:	83 ec 08             	sub    $0x8,%esp
    22e5:	68 d3 45 00 00       	push   $0x45d3
    22ea:	6a 01                	push   $0x1
    22ec:	e8 93 15 00 00       	call   3884 <printf>
}
    22f1:	83 c4 10             	add    $0x10,%esp
    22f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
    22f7:	5b                   	pop    %ebx
    22f8:	5e                   	pop    %esi
    22f9:	5f                   	pop    %edi
    22fa:	5d                   	pop    %ebp
    22fb:	c3                   	ret    

000022fc <bigfile>:

void
bigfile(void)
{
    22fc:	55                   	push   %ebp
    22fd:	89 e5                	mov    %esp,%ebp
    22ff:	57                   	push   %edi
    2300:	56                   	push   %esi
    2301:	53                   	push   %ebx
    2302:	83 ec 14             	sub    $0x14,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2305:	68 e0 45 00 00       	push   $0x45e0
    230a:	6a 01                	push   $0x1
    230c:	e8 73 15 00 00       	call   3884 <printf>

  unlink("bigfile");
    2311:	c7 04 24 fc 45 00 00 	movl   $0x45fc,(%esp)
    2318:	e8 52 14 00 00       	call   376f <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    231d:	83 c4 08             	add    $0x8,%esp
    2320:	68 02 02 00 00       	push   $0x202
    2325:	68 fc 45 00 00       	push   $0x45fc
    232a:	e8 30 14 00 00       	call   375f <open>
  if(fd < 0){
    232f:	83 c4 10             	add    $0x10,%esp
    2332:	85 c0                	test   %eax,%eax
    2334:	78 41                	js     2377 <bigfile+0x7b>
    2336:	89 c6                	mov    %eax,%esi
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    2338:	bb 00 00 00 00       	mov    $0x0,%ebx
    233d:	83 fb 13             	cmp    $0x13,%ebx
    2340:	7f 5d                	jg     239f <bigfile+0xa3>
    memset(buf, i, 600);
    2342:	83 ec 04             	sub    $0x4,%esp
    2345:	68 58 02 00 00       	push   $0x258
    234a:	53                   	push   %ebx
    234b:	68 80 7a 00 00       	push   $0x7a80
    2350:	e8 8f 12 00 00       	call   35e4 <memset>
    if(write(fd, buf, 600) != 600){
    2355:	83 c4 0c             	add    $0xc,%esp
    2358:	68 58 02 00 00       	push   $0x258
    235d:	68 80 7a 00 00       	push   $0x7a80
    2362:	56                   	push   %esi
    2363:	e8 d7 13 00 00       	call   373f <write>
    2368:	83 c4 10             	add    $0x10,%esp
    236b:	3d 58 02 00 00       	cmp    $0x258,%eax
    2370:	75 19                	jne    238b <bigfile+0x8f>
  for(i = 0; i < 20; i++){
    2372:	83 c3 01             	add    $0x1,%ebx
    2375:	eb c6                	jmp    233d <bigfile+0x41>
    printf(1, "cannot create bigfile");
    2377:	83 ec 08             	sub    $0x8,%esp
    237a:	68 ee 45 00 00       	push   $0x45ee
    237f:	6a 01                	push   $0x1
    2381:	e8 fe 14 00 00       	call   3884 <printf>
    exit();
    2386:	e8 94 13 00 00       	call   371f <exit>
      printf(1, "write bigfile failed\n");
    238b:	83 ec 08             	sub    $0x8,%esp
    238e:	68 04 46 00 00       	push   $0x4604
    2393:	6a 01                	push   $0x1
    2395:	e8 ea 14 00 00       	call   3884 <printf>
      exit();
    239a:	e8 80 13 00 00       	call   371f <exit>
    }
  }
  close(fd);
    239f:	83 ec 0c             	sub    $0xc,%esp
    23a2:	56                   	push   %esi
    23a3:	e8 9f 13 00 00       	call   3747 <close>

  fd = open("bigfile", 0);
    23a8:	83 c4 08             	add    $0x8,%esp
    23ab:	6a 00                	push   $0x0
    23ad:	68 fc 45 00 00       	push   $0x45fc
    23b2:	e8 a8 13 00 00       	call   375f <open>
    23b7:	89 c7                	mov    %eax,%edi
  if(fd < 0){
    23b9:	83 c4 10             	add    $0x10,%esp
    23bc:	85 c0                	test   %eax,%eax
    23be:	78 53                	js     2413 <bigfile+0x117>
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
    23c0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; ; i++){
    23c5:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(fd, buf, 300);
    23ca:	83 ec 04             	sub    $0x4,%esp
    23cd:	68 2c 01 00 00       	push   $0x12c
    23d2:	68 80 7a 00 00       	push   $0x7a80
    23d7:	57                   	push   %edi
    23d8:	e8 5a 13 00 00       	call   3737 <read>
    if(cc < 0){
    23dd:	83 c4 10             	add    $0x10,%esp
    23e0:	85 c0                	test   %eax,%eax
    23e2:	78 43                	js     2427 <bigfile+0x12b>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
    23e4:	74 7d                	je     2463 <bigfile+0x167>
      break;
    if(cc != 300){
    23e6:	3d 2c 01 00 00       	cmp    $0x12c,%eax
    23eb:	75 4e                	jne    243b <bigfile+0x13f>
      printf(1, "short read bigfile\n");
      exit();
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    23ed:	0f be 0d 80 7a 00 00 	movsbl 0x7a80,%ecx
    23f4:	89 da                	mov    %ebx,%edx
    23f6:	c1 ea 1f             	shr    $0x1f,%edx
    23f9:	01 da                	add    %ebx,%edx
    23fb:	d1 fa                	sar    %edx
    23fd:	39 d1                	cmp    %edx,%ecx
    23ff:	75 4e                	jne    244f <bigfile+0x153>
    2401:	0f be 0d ab 7b 00 00 	movsbl 0x7bab,%ecx
    2408:	39 ca                	cmp    %ecx,%edx
    240a:	75 43                	jne    244f <bigfile+0x153>
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
    240c:	01 c6                	add    %eax,%esi
  for(i = 0; ; i++){
    240e:	83 c3 01             	add    $0x1,%ebx
    cc = read(fd, buf, 300);
    2411:	eb b7                	jmp    23ca <bigfile+0xce>
    printf(1, "cannot open bigfile\n");
    2413:	83 ec 08             	sub    $0x8,%esp
    2416:	68 1a 46 00 00       	push   $0x461a
    241b:	6a 01                	push   $0x1
    241d:	e8 62 14 00 00       	call   3884 <printf>
    exit();
    2422:	e8 f8 12 00 00       	call   371f <exit>
      printf(1, "read bigfile failed\n");
    2427:	83 ec 08             	sub    $0x8,%esp
    242a:	68 2f 46 00 00       	push   $0x462f
    242f:	6a 01                	push   $0x1
    2431:	e8 4e 14 00 00       	call   3884 <printf>
      exit();
    2436:	e8 e4 12 00 00       	call   371f <exit>
      printf(1, "short read bigfile\n");
    243b:	83 ec 08             	sub    $0x8,%esp
    243e:	68 44 46 00 00       	push   $0x4644
    2443:	6a 01                	push   $0x1
    2445:	e8 3a 14 00 00       	call   3884 <printf>
      exit();
    244a:	e8 d0 12 00 00       	call   371f <exit>
      printf(1, "read bigfile wrong data\n");
    244f:	83 ec 08             	sub    $0x8,%esp
    2452:	68 58 46 00 00       	push   $0x4658
    2457:	6a 01                	push   $0x1
    2459:	e8 26 14 00 00       	call   3884 <printf>
      exit();
    245e:	e8 bc 12 00 00       	call   371f <exit>
  }
  close(fd);
    2463:	83 ec 0c             	sub    $0xc,%esp
    2466:	57                   	push   %edi
    2467:	e8 db 12 00 00       	call   3747 <close>
  if(total != 20*600){
    246c:	83 c4 10             	add    $0x10,%esp
    246f:	81 fe e0 2e 00 00    	cmp    $0x2ee0,%esi
    2475:	75 27                	jne    249e <bigfile+0x1a2>
    printf(1, "read bigfile wrong total\n");
    exit();
  }
  unlink("bigfile");
    2477:	83 ec 0c             	sub    $0xc,%esp
    247a:	68 fc 45 00 00       	push   $0x45fc
    247f:	e8 eb 12 00 00       	call   376f <unlink>

  printf(1, "bigfile test ok\n");
    2484:	83 c4 08             	add    $0x8,%esp
    2487:	68 8b 46 00 00       	push   $0x468b
    248c:	6a 01                	push   $0x1
    248e:	e8 f1 13 00 00       	call   3884 <printf>
}
    2493:	83 c4 10             	add    $0x10,%esp
    2496:	8d 65 f4             	lea    -0xc(%ebp),%esp
    2499:	5b                   	pop    %ebx
    249a:	5e                   	pop    %esi
    249b:	5f                   	pop    %edi
    249c:	5d                   	pop    %ebp
    249d:	c3                   	ret    
    printf(1, "read bigfile wrong total\n");
    249e:	83 ec 08             	sub    $0x8,%esp
    24a1:	68 71 46 00 00       	push   $0x4671
    24a6:	6a 01                	push   $0x1
    24a8:	e8 d7 13 00 00       	call   3884 <printf>
    exit();
    24ad:	e8 6d 12 00 00       	call   371f <exit>

000024b2 <fourteen>:

void
fourteen(void)
{
    24b2:	55                   	push   %ebp
    24b3:	89 e5                	mov    %esp,%ebp
    24b5:	83 ec 10             	sub    $0x10,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    24b8:	68 9c 46 00 00       	push   $0x469c
    24bd:	6a 01                	push   $0x1
    24bf:	e8 c0 13 00 00       	call   3884 <printf>

  if(mkdir("12345678901234") != 0){
    24c4:	c7 04 24 d7 46 00 00 	movl   $0x46d7,(%esp)
    24cb:	e8 b7 12 00 00       	call   3787 <mkdir>
    24d0:	83 c4 10             	add    $0x10,%esp
    24d3:	85 c0                	test   %eax,%eax
    24d5:	0f 85 9c 00 00 00    	jne    2577 <fourteen+0xc5>
    printf(1, "mkdir 12345678901234 failed\n");
    exit();
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    24db:	83 ec 0c             	sub    $0xc,%esp
    24de:	68 94 4e 00 00       	push   $0x4e94
    24e3:	e8 9f 12 00 00       	call   3787 <mkdir>
    24e8:	83 c4 10             	add    $0x10,%esp
    24eb:	85 c0                	test   %eax,%eax
    24ed:	0f 85 98 00 00 00    	jne    258b <fourteen+0xd9>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    exit();
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    24f3:	83 ec 08             	sub    $0x8,%esp
    24f6:	68 00 02 00 00       	push   $0x200
    24fb:	68 e4 4e 00 00       	push   $0x4ee4
    2500:	e8 5a 12 00 00       	call   375f <open>
  if(fd < 0){
    2505:	83 c4 10             	add    $0x10,%esp
    2508:	85 c0                	test   %eax,%eax
    250a:	0f 88 8f 00 00 00    	js     259f <fourteen+0xed>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    exit();
  }
  close(fd);
    2510:	83 ec 0c             	sub    $0xc,%esp
    2513:	50                   	push   %eax
    2514:	e8 2e 12 00 00       	call   3747 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2519:	83 c4 08             	add    $0x8,%esp
    251c:	6a 00                	push   $0x0
    251e:	68 54 4f 00 00       	push   $0x4f54
    2523:	e8 37 12 00 00       	call   375f <open>
  if(fd < 0){
    2528:	83 c4 10             	add    $0x10,%esp
    252b:	85 c0                	test   %eax,%eax
    252d:	0f 88 80 00 00 00    	js     25b3 <fourteen+0x101>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    exit();
  }
  close(fd);
    2533:	83 ec 0c             	sub    $0xc,%esp
    2536:	50                   	push   %eax
    2537:	e8 0b 12 00 00       	call   3747 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    253c:	c7 04 24 c8 46 00 00 	movl   $0x46c8,(%esp)
    2543:	e8 3f 12 00 00       	call   3787 <mkdir>
    2548:	83 c4 10             	add    $0x10,%esp
    254b:	85 c0                	test   %eax,%eax
    254d:	74 78                	je     25c7 <fourteen+0x115>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    exit();
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    254f:	83 ec 0c             	sub    $0xc,%esp
    2552:	68 f0 4f 00 00       	push   $0x4ff0
    2557:	e8 2b 12 00 00       	call   3787 <mkdir>
    255c:	83 c4 10             	add    $0x10,%esp
    255f:	85 c0                	test   %eax,%eax
    2561:	74 78                	je     25db <fourteen+0x129>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    exit();
  }

  printf(1, "fourteen ok\n");
    2563:	83 ec 08             	sub    $0x8,%esp
    2566:	68 e6 46 00 00       	push   $0x46e6
    256b:	6a 01                	push   $0x1
    256d:	e8 12 13 00 00       	call   3884 <printf>
}
    2572:	83 c4 10             	add    $0x10,%esp
    2575:	c9                   	leave  
    2576:	c3                   	ret    
    printf(1, "mkdir 12345678901234 failed\n");
    2577:	83 ec 08             	sub    $0x8,%esp
    257a:	68 ab 46 00 00       	push   $0x46ab
    257f:	6a 01                	push   $0x1
    2581:	e8 fe 12 00 00       	call   3884 <printf>
    exit();
    2586:	e8 94 11 00 00       	call   371f <exit>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    258b:	83 ec 08             	sub    $0x8,%esp
    258e:	68 b4 4e 00 00       	push   $0x4eb4
    2593:	6a 01                	push   $0x1
    2595:	e8 ea 12 00 00       	call   3884 <printf>
    exit();
    259a:	e8 80 11 00 00       	call   371f <exit>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    259f:	83 ec 08             	sub    $0x8,%esp
    25a2:	68 14 4f 00 00       	push   $0x4f14
    25a7:	6a 01                	push   $0x1
    25a9:	e8 d6 12 00 00       	call   3884 <printf>
    exit();
    25ae:	e8 6c 11 00 00       	call   371f <exit>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    25b3:	83 ec 08             	sub    $0x8,%esp
    25b6:	68 84 4f 00 00       	push   $0x4f84
    25bb:	6a 01                	push   $0x1
    25bd:	e8 c2 12 00 00       	call   3884 <printf>
    exit();
    25c2:	e8 58 11 00 00       	call   371f <exit>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    25c7:	83 ec 08             	sub    $0x8,%esp
    25ca:	68 c0 4f 00 00       	push   $0x4fc0
    25cf:	6a 01                	push   $0x1
    25d1:	e8 ae 12 00 00       	call   3884 <printf>
    exit();
    25d6:	e8 44 11 00 00       	call   371f <exit>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    25db:	83 ec 08             	sub    $0x8,%esp
    25de:	68 10 50 00 00       	push   $0x5010
    25e3:	6a 01                	push   $0x1
    25e5:	e8 9a 12 00 00       	call   3884 <printf>
    exit();
    25ea:	e8 30 11 00 00       	call   371f <exit>

000025ef <rmdot>:

void
rmdot(void)
{
    25ef:	55                   	push   %ebp
    25f0:	89 e5                	mov    %esp,%ebp
    25f2:	83 ec 10             	sub    $0x10,%esp
  printf(1, "rmdot test\n");
    25f5:	68 f3 46 00 00       	push   $0x46f3
    25fa:	6a 01                	push   $0x1
    25fc:	e8 83 12 00 00       	call   3884 <printf>
  if(mkdir("dots") != 0){
    2601:	c7 04 24 ff 46 00 00 	movl   $0x46ff,(%esp)
    2608:	e8 7a 11 00 00       	call   3787 <mkdir>
    260d:	83 c4 10             	add    $0x10,%esp
    2610:	85 c0                	test   %eax,%eax
    2612:	0f 85 bc 00 00 00    	jne    26d4 <rmdot+0xe5>
    printf(1, "mkdir dots failed\n");
    exit();
  }
  if(chdir("dots") != 0){
    2618:	83 ec 0c             	sub    $0xc,%esp
    261b:	68 ff 46 00 00       	push   $0x46ff
    2620:	e8 6a 11 00 00       	call   378f <chdir>
    2625:	83 c4 10             	add    $0x10,%esp
    2628:	85 c0                	test   %eax,%eax
    262a:	0f 85 b8 00 00 00    	jne    26e8 <rmdot+0xf9>
    printf(1, "chdir dots failed\n");
    exit();
  }
  if(unlink(".") == 0){
    2630:	83 ec 0c             	sub    $0xc,%esp
    2633:	68 aa 43 00 00       	push   $0x43aa
    2638:	e8 32 11 00 00       	call   376f <unlink>
    263d:	83 c4 10             	add    $0x10,%esp
    2640:	85 c0                	test   %eax,%eax
    2642:	0f 84 b4 00 00 00    	je     26fc <rmdot+0x10d>
    printf(1, "rm . worked!\n");
    exit();
  }
  if(unlink("..") == 0){
    2648:	83 ec 0c             	sub    $0xc,%esp
    264b:	68 a9 43 00 00       	push   $0x43a9
    2650:	e8 1a 11 00 00       	call   376f <unlink>
    2655:	83 c4 10             	add    $0x10,%esp
    2658:	85 c0                	test   %eax,%eax
    265a:	0f 84 b0 00 00 00    	je     2710 <rmdot+0x121>
    printf(1, "rm .. worked!\n");
    exit();
  }
  if(chdir("/") != 0){
    2660:	83 ec 0c             	sub    $0xc,%esp
    2663:	68 7d 3b 00 00       	push   $0x3b7d
    2668:	e8 22 11 00 00       	call   378f <chdir>
    266d:	83 c4 10             	add    $0x10,%esp
    2670:	85 c0                	test   %eax,%eax
    2672:	0f 85 ac 00 00 00    	jne    2724 <rmdot+0x135>
    printf(1, "chdir / failed\n");
    exit();
  }
  if(unlink("dots/.") == 0){
    2678:	83 ec 0c             	sub    $0xc,%esp
    267b:	68 47 47 00 00       	push   $0x4747
    2680:	e8 ea 10 00 00       	call   376f <unlink>
    2685:	83 c4 10             	add    $0x10,%esp
    2688:	85 c0                	test   %eax,%eax
    268a:	0f 84 a8 00 00 00    	je     2738 <rmdot+0x149>
    printf(1, "unlink dots/. worked!\n");
    exit();
  }
  if(unlink("dots/..") == 0){
    2690:	83 ec 0c             	sub    $0xc,%esp
    2693:	68 65 47 00 00       	push   $0x4765
    2698:	e8 d2 10 00 00       	call   376f <unlink>
    269d:	83 c4 10             	add    $0x10,%esp
    26a0:	85 c0                	test   %eax,%eax
    26a2:	0f 84 a4 00 00 00    	je     274c <rmdot+0x15d>
    printf(1, "unlink dots/.. worked!\n");
    exit();
  }
  if(unlink("dots") != 0){
    26a8:	83 ec 0c             	sub    $0xc,%esp
    26ab:	68 ff 46 00 00       	push   $0x46ff
    26b0:	e8 ba 10 00 00       	call   376f <unlink>
    26b5:	83 c4 10             	add    $0x10,%esp
    26b8:	85 c0                	test   %eax,%eax
    26ba:	0f 85 a0 00 00 00    	jne    2760 <rmdot+0x171>
    printf(1, "unlink dots failed!\n");
    exit();
  }
  printf(1, "rmdot ok\n");
    26c0:	83 ec 08             	sub    $0x8,%esp
    26c3:	68 9a 47 00 00       	push   $0x479a
    26c8:	6a 01                	push   $0x1
    26ca:	e8 b5 11 00 00       	call   3884 <printf>
}
    26cf:	83 c4 10             	add    $0x10,%esp
    26d2:	c9                   	leave  
    26d3:	c3                   	ret    
    printf(1, "mkdir dots failed\n");
    26d4:	83 ec 08             	sub    $0x8,%esp
    26d7:	68 04 47 00 00       	push   $0x4704
    26dc:	6a 01                	push   $0x1
    26de:	e8 a1 11 00 00       	call   3884 <printf>
    exit();
    26e3:	e8 37 10 00 00       	call   371f <exit>
    printf(1, "chdir dots failed\n");
    26e8:	83 ec 08             	sub    $0x8,%esp
    26eb:	68 17 47 00 00       	push   $0x4717
    26f0:	6a 01                	push   $0x1
    26f2:	e8 8d 11 00 00       	call   3884 <printf>
    exit();
    26f7:	e8 23 10 00 00       	call   371f <exit>
    printf(1, "rm . worked!\n");
    26fc:	83 ec 08             	sub    $0x8,%esp
    26ff:	68 2a 47 00 00       	push   $0x472a
    2704:	6a 01                	push   $0x1
    2706:	e8 79 11 00 00       	call   3884 <printf>
    exit();
    270b:	e8 0f 10 00 00       	call   371f <exit>
    printf(1, "rm .. worked!\n");
    2710:	83 ec 08             	sub    $0x8,%esp
    2713:	68 38 47 00 00       	push   $0x4738
    2718:	6a 01                	push   $0x1
    271a:	e8 65 11 00 00       	call   3884 <printf>
    exit();
    271f:	e8 fb 0f 00 00       	call   371f <exit>
    printf(1, "chdir / failed\n");
    2724:	83 ec 08             	sub    $0x8,%esp
    2727:	68 7f 3b 00 00       	push   $0x3b7f
    272c:	6a 01                	push   $0x1
    272e:	e8 51 11 00 00       	call   3884 <printf>
    exit();
    2733:	e8 e7 0f 00 00       	call   371f <exit>
    printf(1, "unlink dots/. worked!\n");
    2738:	83 ec 08             	sub    $0x8,%esp
    273b:	68 4e 47 00 00       	push   $0x474e
    2740:	6a 01                	push   $0x1
    2742:	e8 3d 11 00 00       	call   3884 <printf>
    exit();
    2747:	e8 d3 0f 00 00       	call   371f <exit>
    printf(1, "unlink dots/.. worked!\n");
    274c:	83 ec 08             	sub    $0x8,%esp
    274f:	68 6d 47 00 00       	push   $0x476d
    2754:	6a 01                	push   $0x1
    2756:	e8 29 11 00 00       	call   3884 <printf>
    exit();
    275b:	e8 bf 0f 00 00       	call   371f <exit>
    printf(1, "unlink dots failed!\n");
    2760:	83 ec 08             	sub    $0x8,%esp
    2763:	68 85 47 00 00       	push   $0x4785
    2768:	6a 01                	push   $0x1
    276a:	e8 15 11 00 00       	call   3884 <printf>
    exit();
    276f:	e8 ab 0f 00 00       	call   371f <exit>

00002774 <dirfile>:

void
dirfile(void)
{
    2774:	55                   	push   %ebp
    2775:	89 e5                	mov    %esp,%ebp
    2777:	53                   	push   %ebx
    2778:	83 ec 0c             	sub    $0xc,%esp
  int fd;

  printf(1, "dir vs file\n");
    277b:	68 a4 47 00 00       	push   $0x47a4
    2780:	6a 01                	push   $0x1
    2782:	e8 fd 10 00 00       	call   3884 <printf>

  fd = open("dirfile", O_CREATE);
    2787:	83 c4 08             	add    $0x8,%esp
    278a:	68 00 02 00 00       	push   $0x200
    278f:	68 b1 47 00 00       	push   $0x47b1
    2794:	e8 c6 0f 00 00       	call   375f <open>
  if(fd < 0){
    2799:	83 c4 10             	add    $0x10,%esp
    279c:	85 c0                	test   %eax,%eax
    279e:	0f 88 22 01 00 00    	js     28c6 <dirfile+0x152>
    printf(1, "create dirfile failed\n");
    exit();
  }
  close(fd);
    27a4:	83 ec 0c             	sub    $0xc,%esp
    27a7:	50                   	push   %eax
    27a8:	e8 9a 0f 00 00       	call   3747 <close>
  if(chdir("dirfile") == 0){
    27ad:	c7 04 24 b1 47 00 00 	movl   $0x47b1,(%esp)
    27b4:	e8 d6 0f 00 00       	call   378f <chdir>
    27b9:	83 c4 10             	add    $0x10,%esp
    27bc:	85 c0                	test   %eax,%eax
    27be:	0f 84 16 01 00 00    	je     28da <dirfile+0x166>
    printf(1, "chdir dirfile succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", 0);
    27c4:	83 ec 08             	sub    $0x8,%esp
    27c7:	6a 00                	push   $0x0
    27c9:	68 ea 47 00 00       	push   $0x47ea
    27ce:	e8 8c 0f 00 00       	call   375f <open>
  if(fd >= 0){
    27d3:	83 c4 10             	add    $0x10,%esp
    27d6:	85 c0                	test   %eax,%eax
    27d8:	0f 89 10 01 00 00    	jns    28ee <dirfile+0x17a>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", O_CREATE);
    27de:	83 ec 08             	sub    $0x8,%esp
    27e1:	68 00 02 00 00       	push   $0x200
    27e6:	68 ea 47 00 00       	push   $0x47ea
    27eb:	e8 6f 0f 00 00       	call   375f <open>
  if(fd >= 0){
    27f0:	83 c4 10             	add    $0x10,%esp
    27f3:	85 c0                	test   %eax,%eax
    27f5:	0f 89 07 01 00 00    	jns    2902 <dirfile+0x18e>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  if(mkdir("dirfile/xx") == 0){
    27fb:	83 ec 0c             	sub    $0xc,%esp
    27fe:	68 ea 47 00 00       	push   $0x47ea
    2803:	e8 7f 0f 00 00       	call   3787 <mkdir>
    2808:	83 c4 10             	add    $0x10,%esp
    280b:	85 c0                	test   %eax,%eax
    280d:	0f 84 03 01 00 00    	je     2916 <dirfile+0x1a2>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile/xx") == 0){
    2813:	83 ec 0c             	sub    $0xc,%esp
    2816:	68 ea 47 00 00       	push   $0x47ea
    281b:	e8 4f 0f 00 00       	call   376f <unlink>
    2820:	83 c4 10             	add    $0x10,%esp
    2823:	85 c0                	test   %eax,%eax
    2825:	0f 84 ff 00 00 00    	je     292a <dirfile+0x1b6>
    printf(1, "unlink dirfile/xx succeeded!\n");
    exit();
  }
  if(link("README", "dirfile/xx") == 0){
    282b:	83 ec 08             	sub    $0x8,%esp
    282e:	68 ea 47 00 00       	push   $0x47ea
    2833:	68 4e 48 00 00       	push   $0x484e
    2838:	e8 42 0f 00 00       	call   377f <link>
    283d:	83 c4 10             	add    $0x10,%esp
    2840:	85 c0                	test   %eax,%eax
    2842:	0f 84 f6 00 00 00    	je     293e <dirfile+0x1ca>
    printf(1, "link to dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile") != 0){
    2848:	83 ec 0c             	sub    $0xc,%esp
    284b:	68 b1 47 00 00       	push   $0x47b1
    2850:	e8 1a 0f 00 00       	call   376f <unlink>
    2855:	83 c4 10             	add    $0x10,%esp
    2858:	85 c0                	test   %eax,%eax
    285a:	0f 85 f2 00 00 00    	jne    2952 <dirfile+0x1de>
    printf(1, "unlink dirfile failed!\n");
    exit();
  }

  fd = open(".", O_RDWR);
    2860:	83 ec 08             	sub    $0x8,%esp
    2863:	6a 02                	push   $0x2
    2865:	68 aa 43 00 00       	push   $0x43aa
    286a:	e8 f0 0e 00 00       	call   375f <open>
  if(fd >= 0){
    286f:	83 c4 10             	add    $0x10,%esp
    2872:	85 c0                	test   %eax,%eax
    2874:	0f 89 ec 00 00 00    	jns    2966 <dirfile+0x1f2>
    printf(1, "open . for writing succeeded!\n");
    exit();
  }
  fd = open(".", 0);
    287a:	83 ec 08             	sub    $0x8,%esp
    287d:	6a 00                	push   $0x0
    287f:	68 aa 43 00 00       	push   $0x43aa
    2884:	e8 d6 0e 00 00       	call   375f <open>
    2889:	89 c3                	mov    %eax,%ebx
  if(write(fd, "x", 1) > 0){
    288b:	83 c4 0c             	add    $0xc,%esp
    288e:	6a 01                	push   $0x1
    2890:	68 8d 44 00 00       	push   $0x448d
    2895:	50                   	push   %eax
    2896:	e8 a4 0e 00 00       	call   373f <write>
    289b:	83 c4 10             	add    $0x10,%esp
    289e:	85 c0                	test   %eax,%eax
    28a0:	0f 8f d4 00 00 00    	jg     297a <dirfile+0x206>
    printf(1, "write . succeeded!\n");
    exit();
  }
  close(fd);
    28a6:	83 ec 0c             	sub    $0xc,%esp
    28a9:	53                   	push   %ebx
    28aa:	e8 98 0e 00 00       	call   3747 <close>

  printf(1, "dir vs file OK\n");
    28af:	83 c4 08             	add    $0x8,%esp
    28b2:	68 81 48 00 00       	push   $0x4881
    28b7:	6a 01                	push   $0x1
    28b9:	e8 c6 0f 00 00       	call   3884 <printf>
}
    28be:	83 c4 10             	add    $0x10,%esp
    28c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    28c4:	c9                   	leave  
    28c5:	c3                   	ret    
    printf(1, "create dirfile failed\n");
    28c6:	83 ec 08             	sub    $0x8,%esp
    28c9:	68 b9 47 00 00       	push   $0x47b9
    28ce:	6a 01                	push   $0x1
    28d0:	e8 af 0f 00 00       	call   3884 <printf>
    exit();
    28d5:	e8 45 0e 00 00       	call   371f <exit>
    printf(1, "chdir dirfile succeeded!\n");
    28da:	83 ec 08             	sub    $0x8,%esp
    28dd:	68 d0 47 00 00       	push   $0x47d0
    28e2:	6a 01                	push   $0x1
    28e4:	e8 9b 0f 00 00       	call   3884 <printf>
    exit();
    28e9:	e8 31 0e 00 00       	call   371f <exit>
    printf(1, "create dirfile/xx succeeded!\n");
    28ee:	83 ec 08             	sub    $0x8,%esp
    28f1:	68 f5 47 00 00       	push   $0x47f5
    28f6:	6a 01                	push   $0x1
    28f8:	e8 87 0f 00 00       	call   3884 <printf>
    exit();
    28fd:	e8 1d 0e 00 00       	call   371f <exit>
    printf(1, "create dirfile/xx succeeded!\n");
    2902:	83 ec 08             	sub    $0x8,%esp
    2905:	68 f5 47 00 00       	push   $0x47f5
    290a:	6a 01                	push   $0x1
    290c:	e8 73 0f 00 00       	call   3884 <printf>
    exit();
    2911:	e8 09 0e 00 00       	call   371f <exit>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2916:	83 ec 08             	sub    $0x8,%esp
    2919:	68 13 48 00 00       	push   $0x4813
    291e:	6a 01                	push   $0x1
    2920:	e8 5f 0f 00 00       	call   3884 <printf>
    exit();
    2925:	e8 f5 0d 00 00       	call   371f <exit>
    printf(1, "unlink dirfile/xx succeeded!\n");
    292a:	83 ec 08             	sub    $0x8,%esp
    292d:	68 30 48 00 00       	push   $0x4830
    2932:	6a 01                	push   $0x1
    2934:	e8 4b 0f 00 00       	call   3884 <printf>
    exit();
    2939:	e8 e1 0d 00 00       	call   371f <exit>
    printf(1, "link to dirfile/xx succeeded!\n");
    293e:	83 ec 08             	sub    $0x8,%esp
    2941:	68 44 50 00 00       	push   $0x5044
    2946:	6a 01                	push   $0x1
    2948:	e8 37 0f 00 00       	call   3884 <printf>
    exit();
    294d:	e8 cd 0d 00 00       	call   371f <exit>
    printf(1, "unlink dirfile failed!\n");
    2952:	83 ec 08             	sub    $0x8,%esp
    2955:	68 55 48 00 00       	push   $0x4855
    295a:	6a 01                	push   $0x1
    295c:	e8 23 0f 00 00       	call   3884 <printf>
    exit();
    2961:	e8 b9 0d 00 00       	call   371f <exit>
    printf(1, "open . for writing succeeded!\n");
    2966:	83 ec 08             	sub    $0x8,%esp
    2969:	68 64 50 00 00       	push   $0x5064
    296e:	6a 01                	push   $0x1
    2970:	e8 0f 0f 00 00       	call   3884 <printf>
    exit();
    2975:	e8 a5 0d 00 00       	call   371f <exit>
    printf(1, "write . succeeded!\n");
    297a:	83 ec 08             	sub    $0x8,%esp
    297d:	68 6d 48 00 00       	push   $0x486d
    2982:	6a 01                	push   $0x1
    2984:	e8 fb 0e 00 00       	call   3884 <printf>
    exit();
    2989:	e8 91 0d 00 00       	call   371f <exit>

0000298e <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    298e:	55                   	push   %ebp
    298f:	89 e5                	mov    %esp,%ebp
    2991:	53                   	push   %ebx
    2992:	83 ec 0c             	sub    $0xc,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2995:	68 91 48 00 00       	push   $0x4891
    299a:	6a 01                	push   $0x1
    299c:	e8 e3 0e 00 00       	call   3884 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    29a1:	83 c4 10             	add    $0x10,%esp
    29a4:	bb 00 00 00 00       	mov    $0x0,%ebx
    29a9:	eb 4c                	jmp    29f7 <iref+0x69>
    if(mkdir("irefd") != 0){
      printf(1, "mkdir irefd failed\n");
    29ab:	83 ec 08             	sub    $0x8,%esp
    29ae:	68 a8 48 00 00       	push   $0x48a8
    29b3:	6a 01                	push   $0x1
    29b5:	e8 ca 0e 00 00       	call   3884 <printf>
      exit();
    29ba:	e8 60 0d 00 00       	call   371f <exit>
    }
    if(chdir("irefd") != 0){
      printf(1, "chdir irefd failed\n");
    29bf:	83 ec 08             	sub    $0x8,%esp
    29c2:	68 bc 48 00 00       	push   $0x48bc
    29c7:	6a 01                	push   $0x1
    29c9:	e8 b6 0e 00 00       	call   3884 <printf>
      exit();
    29ce:	e8 4c 0d 00 00       	call   371f <exit>

    mkdir("");
    link("README", "");
    fd = open("", O_CREATE);
    if(fd >= 0)
      close(fd);
    29d3:	83 ec 0c             	sub    $0xc,%esp
    29d6:	50                   	push   %eax
    29d7:	e8 6b 0d 00 00       	call   3747 <close>
    29dc:	83 c4 10             	add    $0x10,%esp
    29df:	e9 80 00 00 00       	jmp    2a64 <iref+0xd6>
    fd = open("xx", O_CREATE);
    if(fd >= 0)
      close(fd);
    unlink("xx");
    29e4:	83 ec 0c             	sub    $0xc,%esp
    29e7:	68 8c 44 00 00       	push   $0x448c
    29ec:	e8 7e 0d 00 00       	call   376f <unlink>
  for(i = 0; i < 50 + 1; i++){
    29f1:	83 c3 01             	add    $0x1,%ebx
    29f4:	83 c4 10             	add    $0x10,%esp
    29f7:	83 fb 32             	cmp    $0x32,%ebx
    29fa:	0f 8f 92 00 00 00    	jg     2a92 <iref+0x104>
    if(mkdir("irefd") != 0){
    2a00:	83 ec 0c             	sub    $0xc,%esp
    2a03:	68 a2 48 00 00       	push   $0x48a2
    2a08:	e8 7a 0d 00 00       	call   3787 <mkdir>
    2a0d:	83 c4 10             	add    $0x10,%esp
    2a10:	85 c0                	test   %eax,%eax
    2a12:	75 97                	jne    29ab <iref+0x1d>
    if(chdir("irefd") != 0){
    2a14:	83 ec 0c             	sub    $0xc,%esp
    2a17:	68 a2 48 00 00       	push   $0x48a2
    2a1c:	e8 6e 0d 00 00       	call   378f <chdir>
    2a21:	83 c4 10             	add    $0x10,%esp
    2a24:	85 c0                	test   %eax,%eax
    2a26:	75 97                	jne    29bf <iref+0x31>
    mkdir("");
    2a28:	83 ec 0c             	sub    $0xc,%esp
    2a2b:	68 57 3f 00 00       	push   $0x3f57
    2a30:	e8 52 0d 00 00       	call   3787 <mkdir>
    link("README", "");
    2a35:	83 c4 08             	add    $0x8,%esp
    2a38:	68 57 3f 00 00       	push   $0x3f57
    2a3d:	68 4e 48 00 00       	push   $0x484e
    2a42:	e8 38 0d 00 00       	call   377f <link>
    fd = open("", O_CREATE);
    2a47:	83 c4 08             	add    $0x8,%esp
    2a4a:	68 00 02 00 00       	push   $0x200
    2a4f:	68 57 3f 00 00       	push   $0x3f57
    2a54:	e8 06 0d 00 00       	call   375f <open>
    if(fd >= 0)
    2a59:	83 c4 10             	add    $0x10,%esp
    2a5c:	85 c0                	test   %eax,%eax
    2a5e:	0f 89 6f ff ff ff    	jns    29d3 <iref+0x45>
    fd = open("xx", O_CREATE);
    2a64:	83 ec 08             	sub    $0x8,%esp
    2a67:	68 00 02 00 00       	push   $0x200
    2a6c:	68 8c 44 00 00       	push   $0x448c
    2a71:	e8 e9 0c 00 00       	call   375f <open>
    if(fd >= 0)
    2a76:	83 c4 10             	add    $0x10,%esp
    2a79:	85 c0                	test   %eax,%eax
    2a7b:	0f 88 63 ff ff ff    	js     29e4 <iref+0x56>
      close(fd);
    2a81:	83 ec 0c             	sub    $0xc,%esp
    2a84:	50                   	push   %eax
    2a85:	e8 bd 0c 00 00       	call   3747 <close>
    2a8a:	83 c4 10             	add    $0x10,%esp
    2a8d:	e9 52 ff ff ff       	jmp    29e4 <iref+0x56>
  }

  chdir("/");
    2a92:	83 ec 0c             	sub    $0xc,%esp
    2a95:	68 7d 3b 00 00       	push   $0x3b7d
    2a9a:	e8 f0 0c 00 00       	call   378f <chdir>
  printf(1, "empty file name OK\n");
    2a9f:	83 c4 08             	add    $0x8,%esp
    2aa2:	68 d0 48 00 00       	push   $0x48d0
    2aa7:	6a 01                	push   $0x1
    2aa9:	e8 d6 0d 00 00       	call   3884 <printf>
}
    2aae:	83 c4 10             	add    $0x10,%esp
    2ab1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    2ab4:	c9                   	leave  
    2ab5:	c3                   	ret    

00002ab6 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    2ab6:	55                   	push   %ebp
    2ab7:	89 e5                	mov    %esp,%ebp
    2ab9:	53                   	push   %ebx
    2aba:	83 ec 0c             	sub    $0xc,%esp
  int n, pid;

  printf(1, "fork test\n");
    2abd:	68 e4 48 00 00       	push   $0x48e4
    2ac2:	6a 01                	push   $0x1
    2ac4:	e8 bb 0d 00 00       	call   3884 <printf>

  for(n=0; n<1000; n++){
    2ac9:	83 c4 10             	add    $0x10,%esp
    2acc:	bb 00 00 00 00       	mov    $0x0,%ebx
    2ad1:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
    2ad7:	7f 15                	jg     2aee <forktest+0x38>
    pid = fork();
    2ad9:	e8 39 0c 00 00       	call   3717 <fork>
    if(pid < 0)
    2ade:	85 c0                	test   %eax,%eax
    2ae0:	78 0c                	js     2aee <forktest+0x38>
      break;
    if(pid == 0)
    2ae2:	74 05                	je     2ae9 <forktest+0x33>
  for(n=0; n<1000; n++){
    2ae4:	83 c3 01             	add    $0x1,%ebx
    2ae7:	eb e8                	jmp    2ad1 <forktest+0x1b>
      exit();
    2ae9:	e8 31 0c 00 00       	call   371f <exit>
  }

  if(n == 1000){
    2aee:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
    2af4:	74 12                	je     2b08 <forktest+0x52>
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }

  for(; n > 0; n--){
    2af6:	85 db                	test   %ebx,%ebx
    2af8:	7e 36                	jle    2b30 <forktest+0x7a>
    if(wait() < 0){
    2afa:	e8 28 0c 00 00       	call   3727 <wait>
    2aff:	85 c0                	test   %eax,%eax
    2b01:	78 19                	js     2b1c <forktest+0x66>
  for(; n > 0; n--){
    2b03:	83 eb 01             	sub    $0x1,%ebx
    2b06:	eb ee                	jmp    2af6 <forktest+0x40>
    printf(1, "fork claimed to work 1000 times!\n");
    2b08:	83 ec 08             	sub    $0x8,%esp
    2b0b:	68 84 50 00 00       	push   $0x5084
    2b10:	6a 01                	push   $0x1
    2b12:	e8 6d 0d 00 00       	call   3884 <printf>
    exit();
    2b17:	e8 03 0c 00 00       	call   371f <exit>
      printf(1, "wait stopped early\n");
    2b1c:	83 ec 08             	sub    $0x8,%esp
    2b1f:	68 ef 48 00 00       	push   $0x48ef
    2b24:	6a 01                	push   $0x1
    2b26:	e8 59 0d 00 00       	call   3884 <printf>
      exit();
    2b2b:	e8 ef 0b 00 00       	call   371f <exit>
    }
  }

  if(wait() != -1){
    2b30:	e8 f2 0b 00 00       	call   3727 <wait>
    2b35:	83 f8 ff             	cmp    $0xffffffff,%eax
    2b38:	75 17                	jne    2b51 <forktest+0x9b>
    printf(1, "wait got too many\n");
    exit();
  }

  printf(1, "fork test OK\n");
    2b3a:	83 ec 08             	sub    $0x8,%esp
    2b3d:	68 16 49 00 00       	push   $0x4916
    2b42:	6a 01                	push   $0x1
    2b44:	e8 3b 0d 00 00       	call   3884 <printf>
}
    2b49:	83 c4 10             	add    $0x10,%esp
    2b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    2b4f:	c9                   	leave  
    2b50:	c3                   	ret    
    printf(1, "wait got too many\n");
    2b51:	83 ec 08             	sub    $0x8,%esp
    2b54:	68 03 49 00 00       	push   $0x4903
    2b59:	6a 01                	push   $0x1
    2b5b:	e8 24 0d 00 00       	call   3884 <printf>
    exit();
    2b60:	e8 ba 0b 00 00       	call   371f <exit>

00002b65 <sbrktest>:

void
sbrktest(void)
{
    2b65:	55                   	push   %ebp
    2b66:	89 e5                	mov    %esp,%ebp
    2b68:	57                   	push   %edi
    2b69:	56                   	push   %esi
    2b6a:	53                   	push   %ebx
    2b6b:	83 ec 54             	sub    $0x54,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    2b6e:	68 24 49 00 00       	push   $0x4924
    2b73:	ff 35 44 53 00 00    	push   0x5344
    2b79:	e8 06 0d 00 00       	call   3884 <printf>
  oldbrk = sbrk(0);
    2b7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2b85:	e8 1d 0c 00 00       	call   37a7 <sbrk>
    2b8a:	89 c7                	mov    %eax,%edi

  // can one sbrk() less than a page?
  a = sbrk(0);
    2b8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2b93:	e8 0f 0c 00 00       	call   37a7 <sbrk>
    2b98:	89 c6                	mov    %eax,%esi
  int i;
  for(i = 0; i < 5000; i++){
    2b9a:	83 c4 10             	add    $0x10,%esp
    2b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
    2ba2:	81 fb 87 13 00 00    	cmp    $0x1387,%ebx
    2ba8:	7f 3a                	jg     2be4 <sbrktest+0x7f>
    b = sbrk(1);
    2baa:	83 ec 0c             	sub    $0xc,%esp
    2bad:	6a 01                	push   $0x1
    2baf:	e8 f3 0b 00 00       	call   37a7 <sbrk>
    if(b != a){
    2bb4:	83 c4 10             	add    $0x10,%esp
    2bb7:	39 c6                	cmp    %eax,%esi
    2bb9:	75 0b                	jne    2bc6 <sbrktest+0x61>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
      exit();
    }
    *b = 1;
    2bbb:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    2bbe:	8d 70 01             	lea    0x1(%eax),%esi
  for(i = 0; i < 5000; i++){
    2bc1:	83 c3 01             	add    $0x1,%ebx
    2bc4:	eb dc                	jmp    2ba2 <sbrktest+0x3d>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    2bc6:	83 ec 0c             	sub    $0xc,%esp
    2bc9:	50                   	push   %eax
    2bca:	56                   	push   %esi
    2bcb:	53                   	push   %ebx
    2bcc:	68 2f 49 00 00       	push   $0x492f
    2bd1:	ff 35 44 53 00 00    	push   0x5344
    2bd7:	e8 a8 0c 00 00       	call   3884 <printf>
      exit();
    2bdc:	83 c4 20             	add    $0x20,%esp
    2bdf:	e8 3b 0b 00 00       	call   371f <exit>
  }
  pid = fork();
    2be4:	e8 2e 0b 00 00       	call   3717 <fork>
    2be9:	89 c3                	mov    %eax,%ebx
  if(pid < 0){
    2beb:	85 c0                	test   %eax,%eax
    2bed:	0f 88 53 01 00 00    	js     2d46 <sbrktest+0x1e1>
    printf(stdout, "sbrk test fork failed\n");
    exit();
  }
  c = sbrk(1);
    2bf3:	83 ec 0c             	sub    $0xc,%esp
    2bf6:	6a 01                	push   $0x1
    2bf8:	e8 aa 0b 00 00       	call   37a7 <sbrk>
  c = sbrk(1);
    2bfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c04:	e8 9e 0b 00 00       	call   37a7 <sbrk>
  if(c != a + 1){
    2c09:	83 c6 01             	add    $0x1,%esi
    2c0c:	83 c4 10             	add    $0x10,%esp
    2c0f:	39 c6                	cmp    %eax,%esi
    2c11:	0f 85 47 01 00 00    	jne    2d5e <sbrktest+0x1f9>
    printf(stdout, "sbrk test failed post-fork\n");
    exit();
  }
  if(pid == 0)
    2c17:	85 db                	test   %ebx,%ebx
    2c19:	0f 84 57 01 00 00    	je     2d76 <sbrktest+0x211>
    exit();
  wait();
    2c1f:	e8 03 0b 00 00       	call   3727 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    2c24:	83 ec 0c             	sub    $0xc,%esp
    2c27:	6a 00                	push   $0x0
    2c29:	e8 79 0b 00 00       	call   37a7 <sbrk>
    2c2e:	89 c3                	mov    %eax,%ebx
  amt = (BIG) - (uint)a;
    2c30:	b8 00 00 40 06       	mov    $0x6400000,%eax
    2c35:	29 d8                	sub    %ebx,%eax
  p = sbrk(amt);
    2c37:	89 04 24             	mov    %eax,(%esp)
    2c3a:	e8 68 0b 00 00       	call   37a7 <sbrk>
  if (p != a) {
    2c3f:	83 c4 10             	add    $0x10,%esp
    2c42:	39 c3                	cmp    %eax,%ebx
    2c44:	0f 85 31 01 00 00    	jne    2d7b <sbrktest+0x216>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    exit();
  }
  lastaddr = (char*) (BIG-1);
  *lastaddr = 99;
    2c4a:	c6 05 ff ff 3f 06 63 	movb   $0x63,0x63fffff

  // can one de-allocate?
  a = sbrk(0);
    2c51:	83 ec 0c             	sub    $0xc,%esp
    2c54:	6a 00                	push   $0x0
    2c56:	e8 4c 0b 00 00       	call   37a7 <sbrk>
    2c5b:	89 c3                	mov    %eax,%ebx
  c = sbrk(-4096);
    2c5d:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    2c64:	e8 3e 0b 00 00       	call   37a7 <sbrk>
  if(c == (char*)0xffffffff){
    2c69:	83 c4 10             	add    $0x10,%esp
    2c6c:	83 f8 ff             	cmp    $0xffffffff,%eax
    2c6f:	0f 84 1e 01 00 00    	je     2d93 <sbrktest+0x22e>
    printf(stdout, "sbrk could not deallocate\n");
    exit();
  }
  c = sbrk(0);
    2c75:	83 ec 0c             	sub    $0xc,%esp
    2c78:	6a 00                	push   $0x0
    2c7a:	e8 28 0b 00 00       	call   37a7 <sbrk>
  if(c != a - 4096){
    2c7f:	8d 93 00 f0 ff ff    	lea    -0x1000(%ebx),%edx
    2c85:	83 c4 10             	add    $0x10,%esp
    2c88:	39 c2                	cmp    %eax,%edx
    2c8a:	0f 85 1b 01 00 00    	jne    2dab <sbrktest+0x246>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    exit();
  }

  // can one re-allocate that page?
  a = sbrk(0);
    2c90:	83 ec 0c             	sub    $0xc,%esp
    2c93:	6a 00                	push   $0x0
    2c95:	e8 0d 0b 00 00       	call   37a7 <sbrk>
    2c9a:	89 c3                	mov    %eax,%ebx
  c = sbrk(4096);
    2c9c:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    2ca3:	e8 ff 0a 00 00       	call   37a7 <sbrk>
    2ca8:	89 c6                	mov    %eax,%esi
  if(c != a || sbrk(0) != a + 4096){
    2caa:	83 c4 10             	add    $0x10,%esp
    2cad:	39 c3                	cmp    %eax,%ebx
    2caf:	0f 85 0d 01 00 00    	jne    2dc2 <sbrktest+0x25d>
    2cb5:	83 ec 0c             	sub    $0xc,%esp
    2cb8:	6a 00                	push   $0x0
    2cba:	e8 e8 0a 00 00       	call   37a7 <sbrk>
    2cbf:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
    2cc5:	83 c4 10             	add    $0x10,%esp
    2cc8:	39 c2                	cmp    %eax,%edx
    2cca:	0f 85 f2 00 00 00    	jne    2dc2 <sbrktest+0x25d>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    exit();
  }
  if(*lastaddr == 99){
    2cd0:	80 3d ff ff 3f 06 63 	cmpb   $0x63,0x63fffff
    2cd7:	0f 84 fc 00 00 00    	je     2dd9 <sbrktest+0x274>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    exit();
  }

  a = sbrk(0);
    2cdd:	83 ec 0c             	sub    $0xc,%esp
    2ce0:	6a 00                	push   $0x0
    2ce2:	e8 c0 0a 00 00       	call   37a7 <sbrk>
    2ce7:	89 c3                	mov    %eax,%ebx
  c = sbrk(-(sbrk(0) - oldbrk));
    2ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2cf0:	e8 b2 0a 00 00       	call   37a7 <sbrk>
    2cf5:	89 c2                	mov    %eax,%edx
    2cf7:	89 f8                	mov    %edi,%eax
    2cf9:	29 d0                	sub    %edx,%eax
    2cfb:	89 04 24             	mov    %eax,(%esp)
    2cfe:	e8 a4 0a 00 00       	call   37a7 <sbrk>
  if(c != a){
    2d03:	83 c4 10             	add    $0x10,%esp
    2d06:	39 c3                	cmp    %eax,%ebx
    2d08:	0f 85 e3 00 00 00    	jne    2df1 <sbrktest+0x28c>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2d0e:	bb 00 00 00 80       	mov    $0x80000000,%ebx
    2d13:	81 fb 7f 84 1e 80    	cmp    $0x801e847f,%ebx
    2d19:	0f 87 23 01 00 00    	ja     2e42 <sbrktest+0x2dd>
    ppid = getpid();
    2d1f:	e8 7b 0a 00 00       	call   379f <getpid>
    2d24:	89 c6                	mov    %eax,%esi
    pid = fork();
    2d26:	e8 ec 09 00 00       	call   3717 <fork>
    if(pid < 0){
    2d2b:	85 c0                	test   %eax,%eax
    2d2d:	0f 88 d5 00 00 00    	js     2e08 <sbrktest+0x2a3>
      printf(stdout, "fork failed\n");
      exit();
    }
    if(pid == 0){
    2d33:	0f 84 e7 00 00 00    	je     2e20 <sbrktest+0x2bb>
      printf(stdout, "oops could read %x = %x\n", a, *a);
      kill(ppid);
      exit();
    }
    wait();
    2d39:	e8 e9 09 00 00       	call   3727 <wait>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2d3e:	81 c3 50 c3 00 00    	add    $0xc350,%ebx
    2d44:	eb cd                	jmp    2d13 <sbrktest+0x1ae>
    printf(stdout, "sbrk test fork failed\n");
    2d46:	83 ec 08             	sub    $0x8,%esp
    2d49:	68 4a 49 00 00       	push   $0x494a
    2d4e:	ff 35 44 53 00 00    	push   0x5344
    2d54:	e8 2b 0b 00 00       	call   3884 <printf>
    exit();
    2d59:	e8 c1 09 00 00       	call   371f <exit>
    printf(stdout, "sbrk test failed post-fork\n");
    2d5e:	83 ec 08             	sub    $0x8,%esp
    2d61:	68 61 49 00 00       	push   $0x4961
    2d66:	ff 35 44 53 00 00    	push   0x5344
    2d6c:	e8 13 0b 00 00       	call   3884 <printf>
    exit();
    2d71:	e8 a9 09 00 00       	call   371f <exit>
    exit();
    2d76:	e8 a4 09 00 00       	call   371f <exit>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    2d7b:	83 ec 08             	sub    $0x8,%esp
    2d7e:	68 a8 50 00 00       	push   $0x50a8
    2d83:	ff 35 44 53 00 00    	push   0x5344
    2d89:	e8 f6 0a 00 00       	call   3884 <printf>
    exit();
    2d8e:	e8 8c 09 00 00       	call   371f <exit>
    printf(stdout, "sbrk could not deallocate\n");
    2d93:	83 ec 08             	sub    $0x8,%esp
    2d96:	68 7d 49 00 00       	push   $0x497d
    2d9b:	ff 35 44 53 00 00    	push   0x5344
    2da1:	e8 de 0a 00 00       	call   3884 <printf>
    exit();
    2da6:	e8 74 09 00 00       	call   371f <exit>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    2dab:	50                   	push   %eax
    2dac:	53                   	push   %ebx
    2dad:	68 e8 50 00 00       	push   $0x50e8
    2db2:	ff 35 44 53 00 00    	push   0x5344
    2db8:	e8 c7 0a 00 00       	call   3884 <printf>
    exit();
    2dbd:	e8 5d 09 00 00       	call   371f <exit>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    2dc2:	56                   	push   %esi
    2dc3:	53                   	push   %ebx
    2dc4:	68 20 51 00 00       	push   $0x5120
    2dc9:	ff 35 44 53 00 00    	push   0x5344
    2dcf:	e8 b0 0a 00 00       	call   3884 <printf>
    exit();
    2dd4:	e8 46 09 00 00       	call   371f <exit>
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    2dd9:	83 ec 08             	sub    $0x8,%esp
    2ddc:	68 48 51 00 00       	push   $0x5148
    2de1:	ff 35 44 53 00 00    	push   0x5344
    2de7:	e8 98 0a 00 00       	call   3884 <printf>
    exit();
    2dec:	e8 2e 09 00 00       	call   371f <exit>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    2df1:	50                   	push   %eax
    2df2:	53                   	push   %ebx
    2df3:	68 78 51 00 00       	push   $0x5178
    2df8:	ff 35 44 53 00 00    	push   0x5344
    2dfe:	e8 81 0a 00 00       	call   3884 <printf>
    exit();
    2e03:	e8 17 09 00 00       	call   371f <exit>
      printf(stdout, "fork failed\n");
    2e08:	83 ec 08             	sub    $0x8,%esp
    2e0b:	68 75 4a 00 00       	push   $0x4a75
    2e10:	ff 35 44 53 00 00    	push   0x5344
    2e16:	e8 69 0a 00 00       	call   3884 <printf>
      exit();
    2e1b:	e8 ff 08 00 00       	call   371f <exit>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    2e20:	0f be 03             	movsbl (%ebx),%eax
    2e23:	50                   	push   %eax
    2e24:	53                   	push   %ebx
    2e25:	68 98 49 00 00       	push   $0x4998
    2e2a:	ff 35 44 53 00 00    	push   0x5344
    2e30:	e8 4f 0a 00 00       	call   3884 <printf>
      kill(ppid);
    2e35:	89 34 24             	mov    %esi,(%esp)
    2e38:	e8 12 09 00 00       	call   374f <kill>
      exit();
    2e3d:	e8 dd 08 00 00       	call   371f <exit>
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    2e42:	83 ec 0c             	sub    $0xc,%esp
    2e45:	8d 45 e0             	lea    -0x20(%ebp),%eax
    2e48:	50                   	push   %eax
    2e49:	e8 e1 08 00 00       	call   372f <pipe>
    2e4e:	89 c3                	mov    %eax,%ebx
    2e50:	83 c4 10             	add    $0x10,%esp
    2e53:	85 c0                	test   %eax,%eax
    2e55:	75 04                	jne    2e5b <sbrktest+0x2f6>
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    2e57:	89 c6                	mov    %eax,%esi
    2e59:	eb 59                	jmp    2eb4 <sbrktest+0x34f>
    printf(1, "pipe() failed\n");
    2e5b:	83 ec 08             	sub    $0x8,%esp
    2e5e:	68 6d 3e 00 00       	push   $0x3e6d
    2e63:	6a 01                	push   $0x1
    2e65:	e8 1a 0a 00 00       	call   3884 <printf>
    exit();
    2e6a:	e8 b0 08 00 00       	call   371f <exit>
    if((pids[i] = fork()) == 0){
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    2e6f:	83 ec 0c             	sub    $0xc,%esp
    2e72:	6a 00                	push   $0x0
    2e74:	e8 2e 09 00 00       	call   37a7 <sbrk>
    2e79:	89 c2                	mov    %eax,%edx
    2e7b:	b8 00 00 40 06       	mov    $0x6400000,%eax
    2e80:	29 d0                	sub    %edx,%eax
    2e82:	89 04 24             	mov    %eax,(%esp)
    2e85:	e8 1d 09 00 00       	call   37a7 <sbrk>
      write(fds[1], "x", 1);
    2e8a:	83 c4 0c             	add    $0xc,%esp
    2e8d:	6a 01                	push   $0x1
    2e8f:	68 8d 44 00 00       	push   $0x448d
    2e94:	ff 75 e4             	push   -0x1c(%ebp)
    2e97:	e8 a3 08 00 00       	call   373f <write>
    2e9c:	83 c4 10             	add    $0x10,%esp
      // sit around until killed
      for(;;) sleep(1000);
    2e9f:	83 ec 0c             	sub    $0xc,%esp
    2ea2:	68 e8 03 00 00       	push   $0x3e8
    2ea7:	e8 03 09 00 00       	call   37af <sleep>
    2eac:	83 c4 10             	add    $0x10,%esp
    2eaf:	eb ee                	jmp    2e9f <sbrktest+0x33a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    2eb1:	83 c6 01             	add    $0x1,%esi
    2eb4:	83 fe 09             	cmp    $0x9,%esi
    2eb7:	77 28                	ja     2ee1 <sbrktest+0x37c>
    if((pids[i] = fork()) == 0){
    2eb9:	e8 59 08 00 00       	call   3717 <fork>
    2ebe:	89 44 b5 b8          	mov    %eax,-0x48(%ebp,%esi,4)
    2ec2:	85 c0                	test   %eax,%eax
    2ec4:	74 a9                	je     2e6f <sbrktest+0x30a>
    }
    if(pids[i] != -1)
    2ec6:	83 f8 ff             	cmp    $0xffffffff,%eax
    2ec9:	74 e6                	je     2eb1 <sbrktest+0x34c>
      read(fds[0], &scratch, 1);
    2ecb:	83 ec 04             	sub    $0x4,%esp
    2ece:	6a 01                	push   $0x1
    2ed0:	8d 45 b7             	lea    -0x49(%ebp),%eax
    2ed3:	50                   	push   %eax
    2ed4:	ff 75 e0             	push   -0x20(%ebp)
    2ed7:	e8 5b 08 00 00       	call   3737 <read>
    2edc:	83 c4 10             	add    $0x10,%esp
    2edf:	eb d0                	jmp    2eb1 <sbrktest+0x34c>
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    2ee1:	83 ec 0c             	sub    $0xc,%esp
    2ee4:	68 00 10 00 00       	push   $0x1000
    2ee9:	e8 b9 08 00 00       	call   37a7 <sbrk>
    2eee:	89 c6                	mov    %eax,%esi
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    2ef0:	83 c4 10             	add    $0x10,%esp
    2ef3:	eb 03                	jmp    2ef8 <sbrktest+0x393>
    2ef5:	83 c3 01             	add    $0x1,%ebx
    2ef8:	83 fb 09             	cmp    $0x9,%ebx
    2efb:	77 1c                	ja     2f19 <sbrktest+0x3b4>
    if(pids[i] == -1)
    2efd:	8b 44 9d b8          	mov    -0x48(%ebp,%ebx,4),%eax
    2f01:	83 f8 ff             	cmp    $0xffffffff,%eax
    2f04:	74 ef                	je     2ef5 <sbrktest+0x390>
      continue;
    kill(pids[i]);
    2f06:	83 ec 0c             	sub    $0xc,%esp
    2f09:	50                   	push   %eax
    2f0a:	e8 40 08 00 00       	call   374f <kill>
    wait();
    2f0f:	e8 13 08 00 00       	call   3727 <wait>
    2f14:	83 c4 10             	add    $0x10,%esp
    2f17:	eb dc                	jmp    2ef5 <sbrktest+0x390>
  }
  if(c == (char*)0xffffffff){
    2f19:	83 fe ff             	cmp    $0xffffffff,%esi
    2f1c:	74 2f                	je     2f4d <sbrktest+0x3e8>
    printf(stdout, "failed sbrk leaked memory\n");
    exit();
  }

  if(sbrk(0) > oldbrk)
    2f1e:	83 ec 0c             	sub    $0xc,%esp
    2f21:	6a 00                	push   $0x0
    2f23:	e8 7f 08 00 00       	call   37a7 <sbrk>
    2f28:	83 c4 10             	add    $0x10,%esp
    2f2b:	39 c7                	cmp    %eax,%edi
    2f2d:	72 36                	jb     2f65 <sbrktest+0x400>
    sbrk(-(sbrk(0) - oldbrk));

  printf(stdout, "sbrk test OK\n");
    2f2f:	83 ec 08             	sub    $0x8,%esp
    2f32:	68 cc 49 00 00       	push   $0x49cc
    2f37:	ff 35 44 53 00 00    	push   0x5344
    2f3d:	e8 42 09 00 00       	call   3884 <printf>
}
    2f42:	83 c4 10             	add    $0x10,%esp
    2f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
    2f48:	5b                   	pop    %ebx
    2f49:	5e                   	pop    %esi
    2f4a:	5f                   	pop    %edi
    2f4b:	5d                   	pop    %ebp
    2f4c:	c3                   	ret    
    printf(stdout, "failed sbrk leaked memory\n");
    2f4d:	83 ec 08             	sub    $0x8,%esp
    2f50:	68 b1 49 00 00       	push   $0x49b1
    2f55:	ff 35 44 53 00 00    	push   0x5344
    2f5b:	e8 24 09 00 00       	call   3884 <printf>
    exit();
    2f60:	e8 ba 07 00 00       	call   371f <exit>
    sbrk(-(sbrk(0) - oldbrk));
    2f65:	83 ec 0c             	sub    $0xc,%esp
    2f68:	6a 00                	push   $0x0
    2f6a:	e8 38 08 00 00       	call   37a7 <sbrk>
    2f6f:	29 c7                	sub    %eax,%edi
    2f71:	89 3c 24             	mov    %edi,(%esp)
    2f74:	e8 2e 08 00 00       	call   37a7 <sbrk>
    2f79:	83 c4 10             	add    $0x10,%esp
    2f7c:	eb b1                	jmp    2f2f <sbrktest+0x3ca>

00002f7e <validateint>:
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    2f7e:	c3                   	ret    

00002f7f <validatetest>:

void
validatetest(void)
{
    2f7f:	55                   	push   %ebp
    2f80:	89 e5                	mov    %esp,%ebp
    2f82:	56                   	push   %esi
    2f83:	53                   	push   %ebx
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    2f84:	83 ec 08             	sub    $0x8,%esp
    2f87:	68 da 49 00 00       	push   $0x49da
    2f8c:	ff 35 44 53 00 00    	push   0x5344
    2f92:	e8 ed 08 00 00       	call   3884 <printf>
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    2f97:	83 c4 10             	add    $0x10,%esp
    2f9a:	be 00 00 00 00       	mov    $0x0,%esi
    2f9f:	81 fe 00 30 11 00    	cmp    $0x113000,%esi
    2fa5:	77 69                	ja     3010 <validatetest+0x91>
    if((pid = fork()) == 0){
    2fa7:	e8 6b 07 00 00       	call   3717 <fork>
    2fac:	89 c3                	mov    %eax,%ebx
    2fae:	85 c0                	test   %eax,%eax
    2fb0:	74 41                	je     2ff3 <validatetest+0x74>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
      exit();
    }
    sleep(0);
    2fb2:	83 ec 0c             	sub    $0xc,%esp
    2fb5:	6a 00                	push   $0x0
    2fb7:	e8 f3 07 00 00       	call   37af <sleep>
    sleep(0);
    2fbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2fc3:	e8 e7 07 00 00       	call   37af <sleep>
    kill(pid);
    2fc8:	89 1c 24             	mov    %ebx,(%esp)
    2fcb:	e8 7f 07 00 00       	call   374f <kill>
    wait();
    2fd0:	e8 52 07 00 00       	call   3727 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    2fd5:	83 c4 08             	add    $0x8,%esp
    2fd8:	56                   	push   %esi
    2fd9:	68 e9 49 00 00       	push   $0x49e9
    2fde:	e8 9c 07 00 00       	call   377f <link>
    2fe3:	83 c4 10             	add    $0x10,%esp
    2fe6:	83 f8 ff             	cmp    $0xffffffff,%eax
    2fe9:	75 0d                	jne    2ff8 <validatetest+0x79>
  for(p = 0; p <= (uint)hi; p += 4096){
    2feb:	81 c6 00 10 00 00    	add    $0x1000,%esi
    2ff1:	eb ac                	jmp    2f9f <validatetest+0x20>
      exit();
    2ff3:	e8 27 07 00 00       	call   371f <exit>
      printf(stdout, "link should not succeed\n");
    2ff8:	83 ec 08             	sub    $0x8,%esp
    2ffb:	68 f4 49 00 00       	push   $0x49f4
    3000:	ff 35 44 53 00 00    	push   0x5344
    3006:	e8 79 08 00 00       	call   3884 <printf>
      exit();
    300b:	e8 0f 07 00 00       	call   371f <exit>
    }
  }

  printf(stdout, "validate ok\n");
    3010:	83 ec 08             	sub    $0x8,%esp
    3013:	68 0d 4a 00 00       	push   $0x4a0d
    3018:	ff 35 44 53 00 00    	push   0x5344
    301e:	e8 61 08 00 00       	call   3884 <printf>
}
    3023:	83 c4 10             	add    $0x10,%esp
    3026:	8d 65 f8             	lea    -0x8(%ebp),%esp
    3029:	5b                   	pop    %ebx
    302a:	5e                   	pop    %esi
    302b:	5d                   	pop    %ebp
    302c:	c3                   	ret    

0000302d <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    302d:	55                   	push   %ebp
    302e:	89 e5                	mov    %esp,%ebp
    3030:	83 ec 10             	sub    $0x10,%esp
  int i;

  printf(stdout, "bss test\n");
    3033:	68 1a 4a 00 00       	push   $0x4a1a
    3038:	ff 35 44 53 00 00    	push   0x5344
    303e:	e8 41 08 00 00       	call   3884 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    3043:	83 c4 10             	add    $0x10,%esp
    3046:	b8 00 00 00 00       	mov    $0x0,%eax
    304b:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    3050:	77 26                	ja     3078 <bsstest+0x4b>
    if(uninit[i] != '\0'){
    3052:	80 b8 60 53 00 00 00 	cmpb   $0x0,0x5360(%eax)
    3059:	75 05                	jne    3060 <bsstest+0x33>
  for(i = 0; i < sizeof(uninit); i++){
    305b:	83 c0 01             	add    $0x1,%eax
    305e:	eb eb                	jmp    304b <bsstest+0x1e>
      printf(stdout, "bss test failed\n");
    3060:	83 ec 08             	sub    $0x8,%esp
    3063:	68 24 4a 00 00       	push   $0x4a24
    3068:	ff 35 44 53 00 00    	push   0x5344
    306e:	e8 11 08 00 00       	call   3884 <printf>
      exit();
    3073:	e8 a7 06 00 00       	call   371f <exit>
    }
  }
  printf(stdout, "bss test ok\n");
    3078:	83 ec 08             	sub    $0x8,%esp
    307b:	68 35 4a 00 00       	push   $0x4a35
    3080:	ff 35 44 53 00 00    	push   0x5344
    3086:	e8 f9 07 00 00       	call   3884 <printf>
}
    308b:	83 c4 10             	add    $0x10,%esp
    308e:	c9                   	leave  
    308f:	c3                   	ret    

00003090 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    3090:	55                   	push   %ebp
    3091:	89 e5                	mov    %esp,%ebp
    3093:	83 ec 14             	sub    $0x14,%esp
  int pid, fd;

  unlink("bigarg-ok");
    3096:	68 42 4a 00 00       	push   $0x4a42
    309b:	e8 cf 06 00 00       	call   376f <unlink>
  pid = fork();
    30a0:	e8 72 06 00 00       	call   3717 <fork>
  if(pid == 0){
    30a5:	83 c4 10             	add    $0x10,%esp
    30a8:	85 c0                	test   %eax,%eax
    30aa:	74 4d                	je     30f9 <bigargtest+0x69>
    exec("echo", args);
    printf(stdout, "bigarg test ok\n");
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit();
  } else if(pid < 0){
    30ac:	0f 88 ad 00 00 00    	js     315f <bigargtest+0xcf>
    printf(stdout, "bigargtest: fork failed\n");
    exit();
  }
  wait();
    30b2:	e8 70 06 00 00       	call   3727 <wait>
  fd = open("bigarg-ok", 0);
    30b7:	83 ec 08             	sub    $0x8,%esp
    30ba:	6a 00                	push   $0x0
    30bc:	68 42 4a 00 00       	push   $0x4a42
    30c1:	e8 99 06 00 00       	call   375f <open>
  if(fd < 0){
    30c6:	83 c4 10             	add    $0x10,%esp
    30c9:	85 c0                	test   %eax,%eax
    30cb:	0f 88 a6 00 00 00    	js     3177 <bigargtest+0xe7>
    printf(stdout, "bigarg test failed!\n");
    exit();
  }
  close(fd);
    30d1:	83 ec 0c             	sub    $0xc,%esp
    30d4:	50                   	push   %eax
    30d5:	e8 6d 06 00 00       	call   3747 <close>
  unlink("bigarg-ok");
    30da:	c7 04 24 42 4a 00 00 	movl   $0x4a42,(%esp)
    30e1:	e8 89 06 00 00       	call   376f <unlink>
}
    30e6:	83 c4 10             	add    $0x10,%esp
    30e9:	c9                   	leave  
    30ea:	c3                   	ret    
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    30eb:	c7 04 85 80 9a 00 00 	movl   $0x519c,0x9a80(,%eax,4)
    30f2:	9c 51 00 00 
    for(i = 0; i < MAXARG-1; i++)
    30f6:	83 c0 01             	add    $0x1,%eax
    30f9:	83 f8 1e             	cmp    $0x1e,%eax
    30fc:	7e ed                	jle    30eb <bigargtest+0x5b>
    args[MAXARG-1] = 0;
    30fe:	c7 05 fc 9a 00 00 00 	movl   $0x0,0x9afc
    3105:	00 00 00 
    printf(stdout, "bigarg test\n");
    3108:	83 ec 08             	sub    $0x8,%esp
    310b:	68 4c 4a 00 00       	push   $0x4a4c
    3110:	ff 35 44 53 00 00    	push   0x5344
    3116:	e8 69 07 00 00       	call   3884 <printf>
    exec("echo", args);
    311b:	83 c4 08             	add    $0x8,%esp
    311e:	68 80 9a 00 00       	push   $0x9a80
    3123:	68 19 3c 00 00       	push   $0x3c19
    3128:	e8 2a 06 00 00       	call   3757 <exec>
    printf(stdout, "bigarg test ok\n");
    312d:	83 c4 08             	add    $0x8,%esp
    3130:	68 59 4a 00 00       	push   $0x4a59
    3135:	ff 35 44 53 00 00    	push   0x5344
    313b:	e8 44 07 00 00       	call   3884 <printf>
    fd = open("bigarg-ok", O_CREATE);
    3140:	83 c4 08             	add    $0x8,%esp
    3143:	68 00 02 00 00       	push   $0x200
    3148:	68 42 4a 00 00       	push   $0x4a42
    314d:	e8 0d 06 00 00       	call   375f <open>
    close(fd);
    3152:	89 04 24             	mov    %eax,(%esp)
    3155:	e8 ed 05 00 00       	call   3747 <close>
    exit();
    315a:	e8 c0 05 00 00       	call   371f <exit>
    printf(stdout, "bigargtest: fork failed\n");
    315f:	83 ec 08             	sub    $0x8,%esp
    3162:	68 69 4a 00 00       	push   $0x4a69
    3167:	ff 35 44 53 00 00    	push   0x5344
    316d:	e8 12 07 00 00       	call   3884 <printf>
    exit();
    3172:	e8 a8 05 00 00       	call   371f <exit>
    printf(stdout, "bigarg test failed!\n");
    3177:	83 ec 08             	sub    $0x8,%esp
    317a:	68 82 4a 00 00       	push   $0x4a82
    317f:	ff 35 44 53 00 00    	push   0x5344
    3185:	e8 fa 06 00 00       	call   3884 <printf>
    exit();
    318a:	e8 90 05 00 00       	call   371f <exit>

0000318f <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    318f:	55                   	push   %ebp
    3190:	89 e5                	mov    %esp,%ebp
    3192:	57                   	push   %edi
    3193:	56                   	push   %esi
    3194:	53                   	push   %ebx
    3195:	83 ec 54             	sub    $0x54,%esp
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");
    3198:	68 97 4a 00 00       	push   $0x4a97
    319d:	6a 01                	push   $0x1
    319f:	e8 e0 06 00 00       	call   3884 <printf>
    31a4:	83 c4 10             	add    $0x10,%esp

  for(nfiles = 0; ; nfiles++){
    31a7:	bb 00 00 00 00       	mov    $0x0,%ebx
    char name[64];
    name[0] = 'f';
    31ac:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    31b0:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    31b5:	89 d8                	mov    %ebx,%eax
    31b7:	f7 ea                	imul   %edx
    31b9:	c1 fa 06             	sar    $0x6,%edx
    31bc:	89 de                	mov    %ebx,%esi
    31be:	c1 fe 1f             	sar    $0x1f,%esi
    31c1:	29 f2                	sub    %esi,%edx
    31c3:	8d 42 30             	lea    0x30(%edx),%eax
    31c6:	88 45 a9             	mov    %al,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    31c9:	69 d2 e8 03 00 00    	imul   $0x3e8,%edx,%edx
    31cf:	89 d9                	mov    %ebx,%ecx
    31d1:	29 d1                	sub    %edx,%ecx
    31d3:	bf 1f 85 eb 51       	mov    $0x51eb851f,%edi
    31d8:	89 c8                	mov    %ecx,%eax
    31da:	f7 ef                	imul   %edi
    31dc:	c1 fa 05             	sar    $0x5,%edx
    31df:	c1 f9 1f             	sar    $0x1f,%ecx
    31e2:	29 ca                	sub    %ecx,%edx
    31e4:	83 c2 30             	add    $0x30,%edx
    31e7:	88 55 aa             	mov    %dl,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    31ea:	89 d8                	mov    %ebx,%eax
    31ec:	f7 ef                	imul   %edi
    31ee:	89 d7                	mov    %edx,%edi
    31f0:	c1 ff 05             	sar    $0x5,%edi
    31f3:	29 f7                	sub    %esi,%edi
    31f5:	6b c7 64             	imul   $0x64,%edi,%eax
    31f8:	89 df                	mov    %ebx,%edi
    31fa:	29 c7                	sub    %eax,%edi
    31fc:	b9 67 66 66 66       	mov    $0x66666667,%ecx
    3201:	89 f8                	mov    %edi,%eax
    3203:	f7 e9                	imul   %ecx
    3205:	c1 fa 02             	sar    $0x2,%edx
    3208:	c1 ff 1f             	sar    $0x1f,%edi
    320b:	29 fa                	sub    %edi,%edx
    320d:	83 c2 30             	add    $0x30,%edx
    3210:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    3213:	89 d8                	mov    %ebx,%eax
    3215:	f7 e9                	imul   %ecx
    3217:	c1 fa 02             	sar    $0x2,%edx
    321a:	29 f2                	sub    %esi,%edx
    321c:	8d 04 92             	lea    (%edx,%edx,4),%eax
    321f:	01 c0                	add    %eax,%eax
    3221:	89 da                	mov    %ebx,%edx
    3223:	29 c2                	sub    %eax,%edx
    3225:	83 c2 30             	add    $0x30,%edx
    3228:	88 55 ac             	mov    %dl,-0x54(%ebp)
    name[5] = '\0';
    322b:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    printf(1, "writing %s\n", name);
    322f:	83 ec 04             	sub    $0x4,%esp
    3232:	8d 75 a8             	lea    -0x58(%ebp),%esi
    3235:	56                   	push   %esi
    3236:	68 a4 4a 00 00       	push   $0x4aa4
    323b:	6a 01                	push   $0x1
    323d:	e8 42 06 00 00       	call   3884 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3242:	83 c4 08             	add    $0x8,%esp
    3245:	68 02 02 00 00       	push   $0x202
    324a:	56                   	push   %esi
    324b:	e8 0f 05 00 00       	call   375f <open>
    3250:	89 c6                	mov    %eax,%esi
    if(fd < 0){
    3252:	83 c4 10             	add    $0x10,%esp
    3255:	85 c0                	test   %eax,%eax
    3257:	79 1b                	jns    3274 <fsfull+0xe5>
      printf(1, "open %s failed\n", name);
    3259:	83 ec 04             	sub    $0x4,%esp
    325c:	8d 45 a8             	lea    -0x58(%ebp),%eax
    325f:	50                   	push   %eax
    3260:	68 b0 4a 00 00       	push   $0x4ab0
    3265:	6a 01                	push   $0x1
    3267:	e8 18 06 00 00       	call   3884 <printf>
      break;
    326c:	83 c4 10             	add    $0x10,%esp
    326f:	e9 e6 00 00 00       	jmp    335a <fsfull+0x1cb>
    }
    int total = 0;
    3274:	bf 00 00 00 00       	mov    $0x0,%edi
    while(1){
      int cc = write(fd, buf, 512);
    3279:	83 ec 04             	sub    $0x4,%esp
    327c:	68 00 02 00 00       	push   $0x200
    3281:	68 80 7a 00 00       	push   $0x7a80
    3286:	56                   	push   %esi
    3287:	e8 b3 04 00 00       	call   373f <write>
      if(cc < 512)
    328c:	83 c4 10             	add    $0x10,%esp
    328f:	3d ff 01 00 00       	cmp    $0x1ff,%eax
    3294:	7e 04                	jle    329a <fsfull+0x10b>
        break;
      total += cc;
    3296:	01 c7                	add    %eax,%edi
    while(1){
    3298:	eb df                	jmp    3279 <fsfull+0xea>
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    329a:	83 ec 04             	sub    $0x4,%esp
    329d:	57                   	push   %edi
    329e:	68 c0 4a 00 00       	push   $0x4ac0
    32a3:	6a 01                	push   $0x1
    32a5:	e8 da 05 00 00       	call   3884 <printf>
    close(fd);
    32aa:	89 34 24             	mov    %esi,(%esp)
    32ad:	e8 95 04 00 00       	call   3747 <close>
    if(total == 0)
    32b2:	83 c4 10             	add    $0x10,%esp
    32b5:	85 ff                	test   %edi,%edi
    32b7:	0f 84 9d 00 00 00    	je     335a <fsfull+0x1cb>
  for(nfiles = 0; ; nfiles++){
    32bd:	83 c3 01             	add    $0x1,%ebx
    32c0:	e9 e7 fe ff ff       	jmp    31ac <fsfull+0x1d>
      break;
  }

  while(nfiles >= 0){
    char name[64];
    name[0] = 'f';
    32c5:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    32c9:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    32ce:	89 d8                	mov    %ebx,%eax
    32d0:	f7 ea                	imul   %edx
    32d2:	c1 fa 06             	sar    $0x6,%edx
    32d5:	89 de                	mov    %ebx,%esi
    32d7:	c1 fe 1f             	sar    $0x1f,%esi
    32da:	29 f2                	sub    %esi,%edx
    32dc:	8d 42 30             	lea    0x30(%edx),%eax
    32df:	88 45 a9             	mov    %al,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    32e2:	69 d2 e8 03 00 00    	imul   $0x3e8,%edx,%edx
    32e8:	89 d9                	mov    %ebx,%ecx
    32ea:	29 d1                	sub    %edx,%ecx
    32ec:	bf 1f 85 eb 51       	mov    $0x51eb851f,%edi
    32f1:	89 c8                	mov    %ecx,%eax
    32f3:	f7 ef                	imul   %edi
    32f5:	c1 fa 05             	sar    $0x5,%edx
    32f8:	c1 f9 1f             	sar    $0x1f,%ecx
    32fb:	29 ca                	sub    %ecx,%edx
    32fd:	83 c2 30             	add    $0x30,%edx
    3300:	88 55 aa             	mov    %dl,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3303:	89 d8                	mov    %ebx,%eax
    3305:	f7 ef                	imul   %edi
    3307:	89 d7                	mov    %edx,%edi
    3309:	c1 ff 05             	sar    $0x5,%edi
    330c:	29 f7                	sub    %esi,%edi
    330e:	6b c7 64             	imul   $0x64,%edi,%eax
    3311:	89 df                	mov    %ebx,%edi
    3313:	29 c7                	sub    %eax,%edi
    3315:	b9 67 66 66 66       	mov    $0x66666667,%ecx
    331a:	89 f8                	mov    %edi,%eax
    331c:	f7 e9                	imul   %ecx
    331e:	c1 fa 02             	sar    $0x2,%edx
    3321:	c1 ff 1f             	sar    $0x1f,%edi
    3324:	29 fa                	sub    %edi,%edx
    3326:	83 c2 30             	add    $0x30,%edx
    3329:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    332c:	89 d8                	mov    %ebx,%eax
    332e:	f7 e9                	imul   %ecx
    3330:	c1 fa 02             	sar    $0x2,%edx
    3333:	29 f2                	sub    %esi,%edx
    3335:	8d 04 92             	lea    (%edx,%edx,4),%eax
    3338:	01 c0                	add    %eax,%eax
    333a:	89 da                	mov    %ebx,%edx
    333c:	29 c2                	sub    %eax,%edx
    333e:	83 c2 30             	add    $0x30,%edx
    3341:	88 55 ac             	mov    %dl,-0x54(%ebp)
    name[5] = '\0';
    3344:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    unlink(name);
    3348:	83 ec 0c             	sub    $0xc,%esp
    334b:	8d 45 a8             	lea    -0x58(%ebp),%eax
    334e:	50                   	push   %eax
    334f:	e8 1b 04 00 00       	call   376f <unlink>
    nfiles--;
    3354:	83 eb 01             	sub    $0x1,%ebx
    3357:	83 c4 10             	add    $0x10,%esp
  while(nfiles >= 0){
    335a:	85 db                	test   %ebx,%ebx
    335c:	0f 89 63 ff ff ff    	jns    32c5 <fsfull+0x136>
  }

  printf(1, "fsfull test finished\n");
    3362:	83 ec 08             	sub    $0x8,%esp
    3365:	68 d0 4a 00 00       	push   $0x4ad0
    336a:	6a 01                	push   $0x1
    336c:	e8 13 05 00 00       	call   3884 <printf>
}
    3371:	83 c4 10             	add    $0x10,%esp
    3374:	8d 65 f4             	lea    -0xc(%ebp),%esp
    3377:	5b                   	pop    %ebx
    3378:	5e                   	pop    %esi
    3379:	5f                   	pop    %edi
    337a:	5d                   	pop    %ebp
    337b:	c3                   	ret    

0000337c <uio>:

void
uio()
{
    337c:	55                   	push   %ebp
    337d:	89 e5                	mov    %esp,%ebp
    337f:	83 ec 10             	sub    $0x10,%esp

  ushort port = 0;
  uchar val = 0;
  int pid;

  printf(1, "uio test\n");
    3382:	68 e6 4a 00 00       	push   $0x4ae6
    3387:	6a 01                	push   $0x1
    3389:	e8 f6 04 00 00       	call   3884 <printf>
  pid = fork();
    338e:	e8 84 03 00 00       	call   3717 <fork>
  if(pid == 0){
    3393:	83 c4 10             	add    $0x10,%esp
    3396:	85 c0                	test   %eax,%eax
    3398:	74 1b                	je     33b5 <uio+0x39>
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    port = RTC_DATA;
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    printf(1, "uio: uio succeeded; test FAILED\n");
    exit();
  } else if(pid < 0){
    339a:	78 3e                	js     33da <uio+0x5e>
    printf (1, "fork failed\n");
    exit();
  }
  wait();
    339c:	e8 86 03 00 00       	call   3727 <wait>
  printf(1, "uio test done\n");
    33a1:	83 ec 08             	sub    $0x8,%esp
    33a4:	68 f0 4a 00 00       	push   $0x4af0
    33a9:	6a 01                	push   $0x1
    33ab:	e8 d4 04 00 00       	call   3884 <printf>
}
    33b0:	83 c4 10             	add    $0x10,%esp
    33b3:	c9                   	leave  
    33b4:	c3                   	ret    
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    33b5:	b8 09 00 00 00       	mov    $0x9,%eax
    33ba:	ba 70 00 00 00       	mov    $0x70,%edx
    33bf:	ee                   	out    %al,(%dx)
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    33c0:	ba 71 00 00 00       	mov    $0x71,%edx
    33c5:	ec                   	in     (%dx),%al
    printf(1, "uio: uio succeeded; test FAILED\n");
    33c6:	83 ec 08             	sub    $0x8,%esp
    33c9:	68 7c 52 00 00       	push   $0x527c
    33ce:	6a 01                	push   $0x1
    33d0:	e8 af 04 00 00       	call   3884 <printf>
    exit();
    33d5:	e8 45 03 00 00       	call   371f <exit>
    printf (1, "fork failed\n");
    33da:	83 ec 08             	sub    $0x8,%esp
    33dd:	68 75 4a 00 00       	push   $0x4a75
    33e2:	6a 01                	push   $0x1
    33e4:	e8 9b 04 00 00       	call   3884 <printf>
    exit();
    33e9:	e8 31 03 00 00       	call   371f <exit>

000033ee <argptest>:

void argptest()
{
    33ee:	55                   	push   %ebp
    33ef:	89 e5                	mov    %esp,%ebp
    33f1:	53                   	push   %ebx
    33f2:	83 ec 0c             	sub    $0xc,%esp
  int fd;
  fd = open("init", O_RDONLY);
    33f5:	6a 00                	push   $0x0
    33f7:	68 ff 4a 00 00       	push   $0x4aff
    33fc:	e8 5e 03 00 00       	call   375f <open>
  if (fd < 0) {
    3401:	83 c4 10             	add    $0x10,%esp
    3404:	85 c0                	test   %eax,%eax
    3406:	78 3a                	js     3442 <argptest+0x54>
    3408:	89 c3                	mov    %eax,%ebx
    printf(2, "open failed\n");
    exit();
  }
  read(fd, sbrk(0) - 1, -1);
    340a:	83 ec 0c             	sub    $0xc,%esp
    340d:	6a 00                	push   $0x0
    340f:	e8 93 03 00 00       	call   37a7 <sbrk>
    3414:	83 e8 01             	sub    $0x1,%eax
    3417:	83 c4 0c             	add    $0xc,%esp
    341a:	6a ff                	push   $0xffffffff
    341c:	50                   	push   %eax
    341d:	53                   	push   %ebx
    341e:	e8 14 03 00 00       	call   3737 <read>
  close(fd);
    3423:	89 1c 24             	mov    %ebx,(%esp)
    3426:	e8 1c 03 00 00       	call   3747 <close>
  printf(1, "arg test passed\n");
    342b:	83 c4 08             	add    $0x8,%esp
    342e:	68 11 4b 00 00       	push   $0x4b11
    3433:	6a 01                	push   $0x1
    3435:	e8 4a 04 00 00       	call   3884 <printf>
}
    343a:	83 c4 10             	add    $0x10,%esp
    343d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    3440:	c9                   	leave  
    3441:	c3                   	ret    
    printf(2, "open failed\n");
    3442:	83 ec 08             	sub    $0x8,%esp
    3445:	68 04 4b 00 00       	push   $0x4b04
    344a:	6a 02                	push   $0x2
    344c:	e8 33 04 00 00       	call   3884 <printf>
    exit();
    3451:	e8 c9 02 00 00       	call   371f <exit>

00003456 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
  randstate = randstate * 1664525 + 1013904223;
    3456:	69 05 40 53 00 00 0d 	imul   $0x19660d,0x5340,%eax
    345d:	66 19 00 
    3460:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    3465:	a3 40 53 00 00       	mov    %eax,0x5340
  return randstate;
}
    346a:	c3                   	ret    

0000346b <main>:

int
main(int argc, char *argv[])
{
    346b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    346f:	83 e4 f0             	and    $0xfffffff0,%esp
    3472:	ff 71 fc             	push   -0x4(%ecx)
    3475:	55                   	push   %ebp
    3476:	89 e5                	mov    %esp,%ebp
    3478:	51                   	push   %ecx
    3479:	83 ec 0c             	sub    $0xc,%esp
  printf(1, "usertests starting\n");
    347c:	68 22 4b 00 00       	push   $0x4b22
    3481:	6a 01                	push   $0x1
    3483:	e8 fc 03 00 00       	call   3884 <printf>

  if(open("usertests.ran", 0) >= 0){
    3488:	83 c4 08             	add    $0x8,%esp
    348b:	6a 00                	push   $0x0
    348d:	68 36 4b 00 00       	push   $0x4b36
    3492:	e8 c8 02 00 00       	call   375f <open>
    3497:	83 c4 10             	add    $0x10,%esp
    349a:	85 c0                	test   %eax,%eax
    349c:	78 14                	js     34b2 <main+0x47>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    349e:	83 ec 08             	sub    $0x8,%esp
    34a1:	68 a0 52 00 00       	push   $0x52a0
    34a6:	6a 01                	push   $0x1
    34a8:	e8 d7 03 00 00       	call   3884 <printf>
    exit();
    34ad:	e8 6d 02 00 00       	call   371f <exit>
  }
  close(open("usertests.ran", O_CREATE));
    34b2:	83 ec 08             	sub    $0x8,%esp
    34b5:	68 00 02 00 00       	push   $0x200
    34ba:	68 36 4b 00 00       	push   $0x4b36
    34bf:	e8 9b 02 00 00       	call   375f <open>
    34c4:	89 04 24             	mov    %eax,(%esp)
    34c7:	e8 7b 02 00 00       	call   3747 <close>

  argptest();
    34cc:	e8 1d ff ff ff       	call   33ee <argptest>
  createdelete();
    34d1:	e8 3c db ff ff       	call   1012 <createdelete>
  linkunlink();
    34d6:	e8 d9 e3 ff ff       	call   18b4 <linkunlink>
  concreate();
    34db:	e8 e6 e0 ff ff       	call   15c6 <concreate>
  fourfiles();
    34e0:	e8 47 d9 ff ff       	call   e2c <fourfiles>
  sharedfd();
    34e5:	e8 a5 d7 ff ff       	call   c8f <sharedfd>

  bigargtest();
    34ea:	e8 a1 fb ff ff       	call   3090 <bigargtest>
  bigwrite();
    34ef:	e8 36 ed ff ff       	call   222a <bigwrite>
  bigargtest();
    34f4:	e8 97 fb ff ff       	call   3090 <bigargtest>
  bsstest();
    34f9:	e8 2f fb ff ff       	call   302d <bsstest>
  sbrktest();
    34fe:	e8 62 f6 ff ff       	call   2b65 <sbrktest>
  validatetest();
    3503:	e8 77 fa ff ff       	call   2f7f <validatetest>

  opentest();
    3508:	e8 9f cd ff ff       	call   2ac <opentest>
  writetest();
    350d:	e8 2d ce ff ff       	call   33f <writetest>
  writetest1();
    3512:	e8 f0 cf ff ff       	call   507 <writetest1>
  createtest();
    3517:	e8 9b d1 ff ff       	call   6b7 <createtest>

  openiputtest();
    351c:	e8 a2 cc ff ff       	call   1c3 <openiputtest>
  exitiputtest();
    3521:	e8 b7 cb ff ff       	call   dd <exitiputtest>
  iputtest();
    3526:	e8 d5 ca ff ff       	call   0 <iputtest>

  mem();
    352b:	e8 a4 d6 ff ff       	call   bd4 <mem>
  pipe1();
    3530:	e8 54 d3 ff ff       	call   889 <pipe1>
  preempt();
    3535:	e8 ef d4 ff ff       	call   a29 <preempt>
  exitwait();
    353a:	e8 25 d6 ff ff       	call   b64 <exitwait>

  rmdot();
    353f:	e8 ab f0 ff ff       	call   25ef <rmdot>
  fourteen();
    3544:	e8 69 ef ff ff       	call   24b2 <fourteen>
  bigfile();
    3549:	e8 ae ed ff ff       	call   22fc <bigfile>
  subdir();
    354e:	e8 a9 e5 ff ff       	call   1afc <subdir>
  linktest();
    3553:	e8 48 de ff ff       	call   13a0 <linktest>
  unlinkread();
    3558:	e8 aa dc ff ff       	call   1207 <unlinkread>
  dirfile();
    355d:	e8 12 f2 ff ff       	call   2774 <dirfile>
  iref();
    3562:	e8 27 f4 ff ff       	call   298e <iref>
  forktest();
    3567:	e8 4a f5 ff ff       	call   2ab6 <forktest>
  bigdir(); // slow
    356c:	e8 37 e4 ff ff       	call   19a8 <bigdir>

  uio();
    3571:	e8 06 fe ff ff       	call   337c <uio>

  exectest();
    3576:	e8 c5 d2 ff ff       	call   840 <exectest>

  exit();
    357b:	e8 9f 01 00 00       	call   371f <exit>

00003580 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
    3580:	55                   	push   %ebp
    3581:	89 e5                	mov    %esp,%ebp
    3583:	56                   	push   %esi
    3584:	53                   	push   %ebx
    3585:	8b 75 08             	mov    0x8(%ebp),%esi
    3588:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    358b:	89 f0                	mov    %esi,%eax
    358d:	89 d1                	mov    %edx,%ecx
    358f:	83 c2 01             	add    $0x1,%edx
    3592:	89 c3                	mov    %eax,%ebx
    3594:	83 c0 01             	add    $0x1,%eax
    3597:	0f b6 09             	movzbl (%ecx),%ecx
    359a:	88 0b                	mov    %cl,(%ebx)
    359c:	84 c9                	test   %cl,%cl
    359e:	75 ed                	jne    358d <strcpy+0xd>
    ;
  return os;
}
    35a0:	89 f0                	mov    %esi,%eax
    35a2:	5b                   	pop    %ebx
    35a3:	5e                   	pop    %esi
    35a4:	5d                   	pop    %ebp
    35a5:	c3                   	ret    

000035a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    35a6:	55                   	push   %ebp
    35a7:	89 e5                	mov    %esp,%ebp
    35a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
    35ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
    35af:	eb 06                	jmp    35b7 <strcmp+0x11>
    p++, q++;
    35b1:	83 c1 01             	add    $0x1,%ecx
    35b4:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
    35b7:	0f b6 01             	movzbl (%ecx),%eax
    35ba:	84 c0                	test   %al,%al
    35bc:	74 04                	je     35c2 <strcmp+0x1c>
    35be:	3a 02                	cmp    (%edx),%al
    35c0:	74 ef                	je     35b1 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
    35c2:	0f b6 c0             	movzbl %al,%eax
    35c5:	0f b6 12             	movzbl (%edx),%edx
    35c8:	29 d0                	sub    %edx,%eax
}
    35ca:	5d                   	pop    %ebp
    35cb:	c3                   	ret    

000035cc <strlen>:

uint
strlen(const char *s)
{
    35cc:	55                   	push   %ebp
    35cd:	89 e5                	mov    %esp,%ebp
    35cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    35d2:	b8 00 00 00 00       	mov    $0x0,%eax
    35d7:	eb 03                	jmp    35dc <strlen+0x10>
    35d9:	83 c0 01             	add    $0x1,%eax
    35dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
    35e0:	75 f7                	jne    35d9 <strlen+0xd>
    ;
  return n;
}
    35e2:	5d                   	pop    %ebp
    35e3:	c3                   	ret    

000035e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
    35e4:	55                   	push   %ebp
    35e5:	89 e5                	mov    %esp,%ebp
    35e7:	57                   	push   %edi
    35e8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    35eb:	89 d7                	mov    %edx,%edi
    35ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
    35f0:	8b 45 0c             	mov    0xc(%ebp),%eax
    35f3:	fc                   	cld    
    35f4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    35f6:	89 d0                	mov    %edx,%eax
    35f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
    35fb:	c9                   	leave  
    35fc:	c3                   	ret    

000035fd <strchr>:

char*
strchr(const char *s, char c)
{
    35fd:	55                   	push   %ebp
    35fe:	89 e5                	mov    %esp,%ebp
    3600:	8b 45 08             	mov    0x8(%ebp),%eax
    3603:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
    3607:	eb 03                	jmp    360c <strchr+0xf>
    3609:	83 c0 01             	add    $0x1,%eax
    360c:	0f b6 10             	movzbl (%eax),%edx
    360f:	84 d2                	test   %dl,%dl
    3611:	74 06                	je     3619 <strchr+0x1c>
    if(*s == c)
    3613:	38 ca                	cmp    %cl,%dl
    3615:	75 f2                	jne    3609 <strchr+0xc>
    3617:	eb 05                	jmp    361e <strchr+0x21>
      return (char*)s;
  return 0;
    3619:	b8 00 00 00 00       	mov    $0x0,%eax
}
    361e:	5d                   	pop    %ebp
    361f:	c3                   	ret    

00003620 <gets>:

char*
gets(char *buf, int max)
{
    3620:	55                   	push   %ebp
    3621:	89 e5                	mov    %esp,%ebp
    3623:	57                   	push   %edi
    3624:	56                   	push   %esi
    3625:	53                   	push   %ebx
    3626:	83 ec 1c             	sub    $0x1c,%esp
    3629:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    362c:	bb 00 00 00 00       	mov    $0x0,%ebx
    3631:	89 de                	mov    %ebx,%esi
    3633:	83 c3 01             	add    $0x1,%ebx
    3636:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    3639:	7d 2e                	jge    3669 <gets+0x49>
    cc = read(0, &c, 1);
    363b:	83 ec 04             	sub    $0x4,%esp
    363e:	6a 01                	push   $0x1
    3640:	8d 45 e7             	lea    -0x19(%ebp),%eax
    3643:	50                   	push   %eax
    3644:	6a 00                	push   $0x0
    3646:	e8 ec 00 00 00       	call   3737 <read>
    if(cc < 1)
    364b:	83 c4 10             	add    $0x10,%esp
    364e:	85 c0                	test   %eax,%eax
    3650:	7e 17                	jle    3669 <gets+0x49>
      break;
    buf[i++] = c;
    3652:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
    3656:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
    3659:	3c 0a                	cmp    $0xa,%al
    365b:	0f 94 c2             	sete   %dl
    365e:	3c 0d                	cmp    $0xd,%al
    3660:	0f 94 c0             	sete   %al
    3663:	08 c2                	or     %al,%dl
    3665:	74 ca                	je     3631 <gets+0x11>
    buf[i++] = c;
    3667:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
    3669:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
    366d:	89 f8                	mov    %edi,%eax
    366f:	8d 65 f4             	lea    -0xc(%ebp),%esp
    3672:	5b                   	pop    %ebx
    3673:	5e                   	pop    %esi
    3674:	5f                   	pop    %edi
    3675:	5d                   	pop    %ebp
    3676:	c3                   	ret    

00003677 <stat>:

int
stat(const char *n, struct stat *st)
{
    3677:	55                   	push   %ebp
    3678:	89 e5                	mov    %esp,%ebp
    367a:	56                   	push   %esi
    367b:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    367c:	83 ec 08             	sub    $0x8,%esp
    367f:	6a 00                	push   $0x0
    3681:	ff 75 08             	push   0x8(%ebp)
    3684:	e8 d6 00 00 00       	call   375f <open>
  if(fd < 0)
    3689:	83 c4 10             	add    $0x10,%esp
    368c:	85 c0                	test   %eax,%eax
    368e:	78 24                	js     36b4 <stat+0x3d>
    3690:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
    3692:	83 ec 08             	sub    $0x8,%esp
    3695:	ff 75 0c             	push   0xc(%ebp)
    3698:	50                   	push   %eax
    3699:	e8 d9 00 00 00       	call   3777 <fstat>
    369e:	89 c6                	mov    %eax,%esi
  close(fd);
    36a0:	89 1c 24             	mov    %ebx,(%esp)
    36a3:	e8 9f 00 00 00       	call   3747 <close>
  return r;
    36a8:	83 c4 10             	add    $0x10,%esp
}
    36ab:	89 f0                	mov    %esi,%eax
    36ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
    36b0:	5b                   	pop    %ebx
    36b1:	5e                   	pop    %esi
    36b2:	5d                   	pop    %ebp
    36b3:	c3                   	ret    
    return -1;
    36b4:	be ff ff ff ff       	mov    $0xffffffff,%esi
    36b9:	eb f0                	jmp    36ab <stat+0x34>

000036bb <atoi>:

int
atoi(const char *s)
{
    36bb:	55                   	push   %ebp
    36bc:	89 e5                	mov    %esp,%ebp
    36be:	53                   	push   %ebx
    36bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
    36c2:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
    36c7:	eb 10                	jmp    36d9 <atoi+0x1e>
    n = n*10 + *s++ - '0';
    36c9:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
    36cc:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
    36cf:	83 c1 01             	add    $0x1,%ecx
    36d2:	0f be c0             	movsbl %al,%eax
    36d5:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
    36d9:	0f b6 01             	movzbl (%ecx),%eax
    36dc:	8d 58 d0             	lea    -0x30(%eax),%ebx
    36df:	80 fb 09             	cmp    $0x9,%bl
    36e2:	76 e5                	jbe    36c9 <atoi+0xe>
  return n;
}
    36e4:	89 d0                	mov    %edx,%eax
    36e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    36e9:	c9                   	leave  
    36ea:	c3                   	ret    

000036eb <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    36eb:	55                   	push   %ebp
    36ec:	89 e5                	mov    %esp,%ebp
    36ee:	56                   	push   %esi
    36ef:	53                   	push   %ebx
    36f0:	8b 75 08             	mov    0x8(%ebp),%esi
    36f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    36f6:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
    36f9:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
    36fb:	eb 0d                	jmp    370a <memmove+0x1f>
    *dst++ = *src++;
    36fd:	0f b6 01             	movzbl (%ecx),%eax
    3700:	88 02                	mov    %al,(%edx)
    3702:	8d 49 01             	lea    0x1(%ecx),%ecx
    3705:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
    3708:	89 d8                	mov    %ebx,%eax
    370a:	8d 58 ff             	lea    -0x1(%eax),%ebx
    370d:	85 c0                	test   %eax,%eax
    370f:	7f ec                	jg     36fd <memmove+0x12>
  return vdst;
}
    3711:	89 f0                	mov    %esi,%eax
    3713:	5b                   	pop    %ebx
    3714:	5e                   	pop    %esi
    3715:	5d                   	pop    %ebp
    3716:	c3                   	ret    

00003717 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3717:	b8 01 00 00 00       	mov    $0x1,%eax
    371c:	cd 40                	int    $0x40
    371e:	c3                   	ret    

0000371f <exit>:
SYSCALL(exit)
    371f:	b8 02 00 00 00       	mov    $0x2,%eax
    3724:	cd 40                	int    $0x40
    3726:	c3                   	ret    

00003727 <wait>:
SYSCALL(wait)
    3727:	b8 03 00 00 00       	mov    $0x3,%eax
    372c:	cd 40                	int    $0x40
    372e:	c3                   	ret    

0000372f <pipe>:
SYSCALL(pipe)
    372f:	b8 04 00 00 00       	mov    $0x4,%eax
    3734:	cd 40                	int    $0x40
    3736:	c3                   	ret    

00003737 <read>:
SYSCALL(read)
    3737:	b8 05 00 00 00       	mov    $0x5,%eax
    373c:	cd 40                	int    $0x40
    373e:	c3                   	ret    

0000373f <write>:
SYSCALL(write)
    373f:	b8 10 00 00 00       	mov    $0x10,%eax
    3744:	cd 40                	int    $0x40
    3746:	c3                   	ret    

00003747 <close>:
SYSCALL(close)
    3747:	b8 15 00 00 00       	mov    $0x15,%eax
    374c:	cd 40                	int    $0x40
    374e:	c3                   	ret    

0000374f <kill>:
SYSCALL(kill)
    374f:	b8 06 00 00 00       	mov    $0x6,%eax
    3754:	cd 40                	int    $0x40
    3756:	c3                   	ret    

00003757 <exec>:
SYSCALL(exec)
    3757:	b8 07 00 00 00       	mov    $0x7,%eax
    375c:	cd 40                	int    $0x40
    375e:	c3                   	ret    

0000375f <open>:
SYSCALL(open)
    375f:	b8 0f 00 00 00       	mov    $0xf,%eax
    3764:	cd 40                	int    $0x40
    3766:	c3                   	ret    

00003767 <mknod>:
SYSCALL(mknod)
    3767:	b8 11 00 00 00       	mov    $0x11,%eax
    376c:	cd 40                	int    $0x40
    376e:	c3                   	ret    

0000376f <unlink>:
SYSCALL(unlink)
    376f:	b8 12 00 00 00       	mov    $0x12,%eax
    3774:	cd 40                	int    $0x40
    3776:	c3                   	ret    

00003777 <fstat>:
SYSCALL(fstat)
    3777:	b8 08 00 00 00       	mov    $0x8,%eax
    377c:	cd 40                	int    $0x40
    377e:	c3                   	ret    

0000377f <link>:
SYSCALL(link)
    377f:	b8 13 00 00 00       	mov    $0x13,%eax
    3784:	cd 40                	int    $0x40
    3786:	c3                   	ret    

00003787 <mkdir>:
SYSCALL(mkdir)
    3787:	b8 14 00 00 00       	mov    $0x14,%eax
    378c:	cd 40                	int    $0x40
    378e:	c3                   	ret    

0000378f <chdir>:
SYSCALL(chdir)
    378f:	b8 09 00 00 00       	mov    $0x9,%eax
    3794:	cd 40                	int    $0x40
    3796:	c3                   	ret    

00003797 <dup>:
SYSCALL(dup)
    3797:	b8 0a 00 00 00       	mov    $0xa,%eax
    379c:	cd 40                	int    $0x40
    379e:	c3                   	ret    

0000379f <getpid>:
SYSCALL(getpid)
    379f:	b8 0b 00 00 00       	mov    $0xb,%eax
    37a4:	cd 40                	int    $0x40
    37a6:	c3                   	ret    

000037a7 <sbrk>:
SYSCALL(sbrk)
    37a7:	b8 0c 00 00 00       	mov    $0xc,%eax
    37ac:	cd 40                	int    $0x40
    37ae:	c3                   	ret    

000037af <sleep>:
SYSCALL(sleep)
    37af:	b8 0d 00 00 00       	mov    $0xd,%eax
    37b4:	cd 40                	int    $0x40
    37b6:	c3                   	ret    

000037b7 <uptime>:
SYSCALL(uptime)
    37b7:	b8 0e 00 00 00       	mov    $0xe,%eax
    37bc:	cd 40                	int    $0x40
    37be:	c3                   	ret    

000037bf <yield>:
SYSCALL(yield)
    37bf:	b8 16 00 00 00       	mov    $0x16,%eax
    37c4:	cd 40                	int    $0x40
    37c6:	c3                   	ret    

000037c7 <shutdown>:
SYSCALL(shutdown)
    37c7:	b8 17 00 00 00       	mov    $0x17,%eax
    37cc:	cd 40                	int    $0x40
    37ce:	c3                   	ret    

000037cf <schedlog>:
SYSCALL(schedlog)
    37cf:	b8 18 00 00 00       	mov    $0x18,%eax
    37d4:	cd 40                	int    $0x40
    37d6:	c3                   	ret    

000037d7 <priofork>:
SYSCALL(priofork)
    37d7:	b8 19 00 00 00       	mov    $0x19,%eax
    37dc:	cd 40                	int    $0x40
    37de:	c3                   	ret    

000037df <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    37df:	55                   	push   %ebp
    37e0:	89 e5                	mov    %esp,%ebp
    37e2:	83 ec 1c             	sub    $0x1c,%esp
    37e5:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
    37e8:	6a 01                	push   $0x1
    37ea:	8d 55 f4             	lea    -0xc(%ebp),%edx
    37ed:	52                   	push   %edx
    37ee:	50                   	push   %eax
    37ef:	e8 4b ff ff ff       	call   373f <write>
}
    37f4:	83 c4 10             	add    $0x10,%esp
    37f7:	c9                   	leave  
    37f8:	c3                   	ret    

000037f9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    37f9:	55                   	push   %ebp
    37fa:	89 e5                	mov    %esp,%ebp
    37fc:	57                   	push   %edi
    37fd:	56                   	push   %esi
    37fe:	53                   	push   %ebx
    37ff:	83 ec 2c             	sub    $0x2c,%esp
    3802:	89 45 d0             	mov    %eax,-0x30(%ebp)
    3805:	89 d0                	mov    %edx,%eax
    3807:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    3809:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    380d:	0f 95 c1             	setne  %cl
    3810:	c1 ea 1f             	shr    $0x1f,%edx
    3813:	84 d1                	test   %dl,%cl
    3815:	74 44                	je     385b <printint+0x62>
    neg = 1;
    x = -xx;
    3817:	f7 d8                	neg    %eax
    3819:	89 c1                	mov    %eax,%ecx
    neg = 1;
    381b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
    3822:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
    3827:	89 c8                	mov    %ecx,%eax
    3829:	ba 00 00 00 00       	mov    $0x0,%edx
    382e:	f7 f6                	div    %esi
    3830:	89 df                	mov    %ebx,%edi
    3832:	83 c3 01             	add    $0x1,%ebx
    3835:	0f b6 92 2c 53 00 00 	movzbl 0x532c(%edx),%edx
    383c:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
    3840:	89 ca                	mov    %ecx,%edx
    3842:	89 c1                	mov    %eax,%ecx
    3844:	39 d6                	cmp    %edx,%esi
    3846:	76 df                	jbe    3827 <printint+0x2e>
  if(neg)
    3848:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
    384c:	74 31                	je     387f <printint+0x86>
    buf[i++] = '-';
    384e:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    3853:	8d 5f 02             	lea    0x2(%edi),%ebx
    3856:	8b 75 d0             	mov    -0x30(%ebp),%esi
    3859:	eb 17                	jmp    3872 <printint+0x79>
    x = xx;
    385b:	89 c1                	mov    %eax,%ecx
  neg = 0;
    385d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    3864:	eb bc                	jmp    3822 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
    3866:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
    386b:	89 f0                	mov    %esi,%eax
    386d:	e8 6d ff ff ff       	call   37df <putc>
  while(--i >= 0)
    3872:	83 eb 01             	sub    $0x1,%ebx
    3875:	79 ef                	jns    3866 <printint+0x6d>
}
    3877:	83 c4 2c             	add    $0x2c,%esp
    387a:	5b                   	pop    %ebx
    387b:	5e                   	pop    %esi
    387c:	5f                   	pop    %edi
    387d:	5d                   	pop    %ebp
    387e:	c3                   	ret    
    387f:	8b 75 d0             	mov    -0x30(%ebp),%esi
    3882:	eb ee                	jmp    3872 <printint+0x79>

00003884 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
    3884:	55                   	push   %ebp
    3885:	89 e5                	mov    %esp,%ebp
    3887:	57                   	push   %edi
    3888:	56                   	push   %esi
    3889:	53                   	push   %ebx
    388a:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    388d:	8d 45 10             	lea    0x10(%ebp),%eax
    3890:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
    3893:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
    3898:	bb 00 00 00 00       	mov    $0x0,%ebx
    389d:	eb 14                	jmp    38b3 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
    389f:	89 fa                	mov    %edi,%edx
    38a1:	8b 45 08             	mov    0x8(%ebp),%eax
    38a4:	e8 36 ff ff ff       	call   37df <putc>
    38a9:	eb 05                	jmp    38b0 <printf+0x2c>
      }
    } else if(state == '%'){
    38ab:	83 fe 25             	cmp    $0x25,%esi
    38ae:	74 25                	je     38d5 <printf+0x51>
  for(i = 0; fmt[i]; i++){
    38b0:	83 c3 01             	add    $0x1,%ebx
    38b3:	8b 45 0c             	mov    0xc(%ebp),%eax
    38b6:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
    38ba:	84 c0                	test   %al,%al
    38bc:	0f 84 20 01 00 00    	je     39e2 <printf+0x15e>
    c = fmt[i] & 0xff;
    38c2:	0f be f8             	movsbl %al,%edi
    38c5:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
    38c8:	85 f6                	test   %esi,%esi
    38ca:	75 df                	jne    38ab <printf+0x27>
      if(c == '%'){
    38cc:	83 f8 25             	cmp    $0x25,%eax
    38cf:	75 ce                	jne    389f <printf+0x1b>
        state = '%';
    38d1:	89 c6                	mov    %eax,%esi
    38d3:	eb db                	jmp    38b0 <printf+0x2c>
      if(c == 'd'){
    38d5:	83 f8 25             	cmp    $0x25,%eax
    38d8:	0f 84 cf 00 00 00    	je     39ad <printf+0x129>
    38de:	0f 8c dd 00 00 00    	jl     39c1 <printf+0x13d>
    38e4:	83 f8 78             	cmp    $0x78,%eax
    38e7:	0f 8f d4 00 00 00    	jg     39c1 <printf+0x13d>
    38ed:	83 f8 63             	cmp    $0x63,%eax
    38f0:	0f 8c cb 00 00 00    	jl     39c1 <printf+0x13d>
    38f6:	83 e8 63             	sub    $0x63,%eax
    38f9:	83 f8 15             	cmp    $0x15,%eax
    38fc:	0f 87 bf 00 00 00    	ja     39c1 <printf+0x13d>
    3902:	ff 24 85 d4 52 00 00 	jmp    *0x52d4(,%eax,4)
        printint(fd, *ap, 10, 1);
    3909:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    390c:	8b 17                	mov    (%edi),%edx
    390e:	83 ec 0c             	sub    $0xc,%esp
    3911:	6a 01                	push   $0x1
    3913:	b9 0a 00 00 00       	mov    $0xa,%ecx
    3918:	8b 45 08             	mov    0x8(%ebp),%eax
    391b:	e8 d9 fe ff ff       	call   37f9 <printint>
        ap++;
    3920:	83 c7 04             	add    $0x4,%edi
    3923:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    3926:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3929:	be 00 00 00 00       	mov    $0x0,%esi
    392e:	eb 80                	jmp    38b0 <printf+0x2c>
        printint(fd, *ap, 16, 0);
    3930:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3933:	8b 17                	mov    (%edi),%edx
    3935:	83 ec 0c             	sub    $0xc,%esp
    3938:	6a 00                	push   $0x0
    393a:	b9 10 00 00 00       	mov    $0x10,%ecx
    393f:	8b 45 08             	mov    0x8(%ebp),%eax
    3942:	e8 b2 fe ff ff       	call   37f9 <printint>
        ap++;
    3947:	83 c7 04             	add    $0x4,%edi
    394a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
    394d:	83 c4 10             	add    $0x10,%esp
      state = 0;
    3950:	be 00 00 00 00       	mov    $0x0,%esi
    3955:	e9 56 ff ff ff       	jmp    38b0 <printf+0x2c>
        s = (char*)*ap;
    395a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    395d:	8b 30                	mov    (%eax),%esi
        ap++;
    395f:	83 c0 04             	add    $0x4,%eax
    3962:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
    3965:	85 f6                	test   %esi,%esi
    3967:	75 15                	jne    397e <printf+0xfa>
          s = "(null)";
    3969:	be ca 52 00 00       	mov    $0x52ca,%esi
    396e:	eb 0e                	jmp    397e <printf+0xfa>
          putc(fd, *s);
    3970:	0f be d2             	movsbl %dl,%edx
    3973:	8b 45 08             	mov    0x8(%ebp),%eax
    3976:	e8 64 fe ff ff       	call   37df <putc>
          s++;
    397b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
    397e:	0f b6 16             	movzbl (%esi),%edx
    3981:	84 d2                	test   %dl,%dl
    3983:	75 eb                	jne    3970 <printf+0xec>
      state = 0;
    3985:	be 00 00 00 00       	mov    $0x0,%esi
    398a:	e9 21 ff ff ff       	jmp    38b0 <printf+0x2c>
        putc(fd, *ap);
    398f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    3992:	0f be 17             	movsbl (%edi),%edx
    3995:	8b 45 08             	mov    0x8(%ebp),%eax
    3998:	e8 42 fe ff ff       	call   37df <putc>
        ap++;
    399d:	83 c7 04             	add    $0x4,%edi
    39a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
    39a3:	be 00 00 00 00       	mov    $0x0,%esi
    39a8:	e9 03 ff ff ff       	jmp    38b0 <printf+0x2c>
        putc(fd, c);
    39ad:	89 fa                	mov    %edi,%edx
    39af:	8b 45 08             	mov    0x8(%ebp),%eax
    39b2:	e8 28 fe ff ff       	call   37df <putc>
      state = 0;
    39b7:	be 00 00 00 00       	mov    $0x0,%esi
    39bc:	e9 ef fe ff ff       	jmp    38b0 <printf+0x2c>
        putc(fd, '%');
    39c1:	ba 25 00 00 00       	mov    $0x25,%edx
    39c6:	8b 45 08             	mov    0x8(%ebp),%eax
    39c9:	e8 11 fe ff ff       	call   37df <putc>
        putc(fd, c);
    39ce:	89 fa                	mov    %edi,%edx
    39d0:	8b 45 08             	mov    0x8(%ebp),%eax
    39d3:	e8 07 fe ff ff       	call   37df <putc>
      state = 0;
    39d8:	be 00 00 00 00       	mov    $0x0,%esi
    39dd:	e9 ce fe ff ff       	jmp    38b0 <printf+0x2c>
    }
  }
}
    39e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
    39e5:	5b                   	pop    %ebx
    39e6:	5e                   	pop    %esi
    39e7:	5f                   	pop    %edi
    39e8:	5d                   	pop    %ebp
    39e9:	c3                   	ret    

000039ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    39ea:	55                   	push   %ebp
    39eb:	89 e5                	mov    %esp,%ebp
    39ed:	57                   	push   %edi
    39ee:	56                   	push   %esi
    39ef:	53                   	push   %ebx
    39f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
    39f3:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    39f6:	a1 00 9b 00 00       	mov    0x9b00,%eax
    39fb:	eb 02                	jmp    39ff <free+0x15>
    39fd:	89 d0                	mov    %edx,%eax
    39ff:	39 c8                	cmp    %ecx,%eax
    3a01:	73 04                	jae    3a07 <free+0x1d>
    3a03:	39 08                	cmp    %ecx,(%eax)
    3a05:	77 12                	ja     3a19 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    3a07:	8b 10                	mov    (%eax),%edx
    3a09:	39 c2                	cmp    %eax,%edx
    3a0b:	77 f0                	ja     39fd <free+0x13>
    3a0d:	39 c8                	cmp    %ecx,%eax
    3a0f:	72 08                	jb     3a19 <free+0x2f>
    3a11:	39 ca                	cmp    %ecx,%edx
    3a13:	77 04                	ja     3a19 <free+0x2f>
    3a15:	89 d0                	mov    %edx,%eax
    3a17:	eb e6                	jmp    39ff <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
    3a19:	8b 73 fc             	mov    -0x4(%ebx),%esi
    3a1c:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
    3a1f:	8b 10                	mov    (%eax),%edx
    3a21:	39 d7                	cmp    %edx,%edi
    3a23:	74 19                	je     3a3e <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
    3a25:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
    3a28:	8b 50 04             	mov    0x4(%eax),%edx
    3a2b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    3a2e:	39 ce                	cmp    %ecx,%esi
    3a30:	74 1b                	je     3a4d <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
    3a32:	89 08                	mov    %ecx,(%eax)
  freep = p;
    3a34:	a3 00 9b 00 00       	mov    %eax,0x9b00
}
    3a39:	5b                   	pop    %ebx
    3a3a:	5e                   	pop    %esi
    3a3b:	5f                   	pop    %edi
    3a3c:	5d                   	pop    %ebp
    3a3d:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
    3a3e:	03 72 04             	add    0x4(%edx),%esi
    3a41:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
    3a44:	8b 10                	mov    (%eax),%edx
    3a46:	8b 12                	mov    (%edx),%edx
    3a48:	89 53 f8             	mov    %edx,-0x8(%ebx)
    3a4b:	eb db                	jmp    3a28 <free+0x3e>
    p->s.size += bp->s.size;
    3a4d:	03 53 fc             	add    -0x4(%ebx),%edx
    3a50:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    3a53:	8b 53 f8             	mov    -0x8(%ebx),%edx
    3a56:	89 10                	mov    %edx,(%eax)
    3a58:	eb da                	jmp    3a34 <free+0x4a>

00003a5a <morecore>:

static Header*
morecore(uint nu)
{
    3a5a:	55                   	push   %ebp
    3a5b:	89 e5                	mov    %esp,%ebp
    3a5d:	53                   	push   %ebx
    3a5e:	83 ec 04             	sub    $0x4,%esp
    3a61:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
    3a63:	3d ff 0f 00 00       	cmp    $0xfff,%eax
    3a68:	77 05                	ja     3a6f <morecore+0x15>
    nu = 4096;
    3a6a:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
    3a6f:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
    3a76:	83 ec 0c             	sub    $0xc,%esp
    3a79:	50                   	push   %eax
    3a7a:	e8 28 fd ff ff       	call   37a7 <sbrk>
  if(p == (char*)-1)
    3a7f:	83 c4 10             	add    $0x10,%esp
    3a82:	83 f8 ff             	cmp    $0xffffffff,%eax
    3a85:	74 1c                	je     3aa3 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    3a87:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
    3a8a:	83 c0 08             	add    $0x8,%eax
    3a8d:	83 ec 0c             	sub    $0xc,%esp
    3a90:	50                   	push   %eax
    3a91:	e8 54 ff ff ff       	call   39ea <free>
  return freep;
    3a96:	a1 00 9b 00 00       	mov    0x9b00,%eax
    3a9b:	83 c4 10             	add    $0x10,%esp
}
    3a9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    3aa1:	c9                   	leave  
    3aa2:	c3                   	ret    
    return 0;
    3aa3:	b8 00 00 00 00       	mov    $0x0,%eax
    3aa8:	eb f4                	jmp    3a9e <morecore+0x44>

00003aaa <malloc>:

void*
malloc(uint nbytes)
{
    3aaa:	55                   	push   %ebp
    3aab:	89 e5                	mov    %esp,%ebp
    3aad:	53                   	push   %ebx
    3aae:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    3ab1:	8b 45 08             	mov    0x8(%ebp),%eax
    3ab4:	8d 58 07             	lea    0x7(%eax),%ebx
    3ab7:	c1 eb 03             	shr    $0x3,%ebx
    3aba:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
    3abd:	8b 0d 00 9b 00 00    	mov    0x9b00,%ecx
    3ac3:	85 c9                	test   %ecx,%ecx
    3ac5:	74 04                	je     3acb <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3ac7:	8b 01                	mov    (%ecx),%eax
    3ac9:	eb 4a                	jmp    3b15 <malloc+0x6b>
    base.s.ptr = freep = prevp = &base;
    3acb:	c7 05 00 9b 00 00 04 	movl   $0x9b04,0x9b00
    3ad2:	9b 00 00 
    3ad5:	c7 05 04 9b 00 00 04 	movl   $0x9b04,0x9b04
    3adc:	9b 00 00 
    base.s.size = 0;
    3adf:	c7 05 08 9b 00 00 00 	movl   $0x0,0x9b08
    3ae6:	00 00 00 
    base.s.ptr = freep = prevp = &base;
    3ae9:	b9 04 9b 00 00       	mov    $0x9b04,%ecx
    3aee:	eb d7                	jmp    3ac7 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
    3af0:	74 19                	je     3b0b <malloc+0x61>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
    3af2:	29 da                	sub    %ebx,%edx
    3af4:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    3af7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
    3afa:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
    3afd:	89 0d 00 9b 00 00    	mov    %ecx,0x9b00
      return (void*)(p + 1);
    3b03:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    3b06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    3b09:	c9                   	leave  
    3b0a:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
    3b0b:	8b 10                	mov    (%eax),%edx
    3b0d:	89 11                	mov    %edx,(%ecx)
    3b0f:	eb ec                	jmp    3afd <malloc+0x53>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3b11:	89 c1                	mov    %eax,%ecx
    3b13:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
    3b15:	8b 50 04             	mov    0x4(%eax),%edx
    3b18:	39 da                	cmp    %ebx,%edx
    3b1a:	73 d4                	jae    3af0 <malloc+0x46>
    if(p == freep)
    3b1c:	39 05 00 9b 00 00    	cmp    %eax,0x9b00
    3b22:	75 ed                	jne    3b11 <malloc+0x67>
      if((p = morecore(nunits)) == 0)
    3b24:	89 d8                	mov    %ebx,%eax
    3b26:	e8 2f ff ff ff       	call   3a5a <morecore>
    3b2b:	85 c0                	test   %eax,%eax
    3b2d:	75 e2                	jne    3b11 <malloc+0x67>
    3b2f:	eb d5                	jmp    3b06 <malloc+0x5c>
