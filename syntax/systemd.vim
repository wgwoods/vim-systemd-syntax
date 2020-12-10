" Filename:     systemd.vim
" Purpose:      Vim syntax file
" Language:     systemd unit files
" Maintainer:   Will Woods <wwoods@redhat.com>
" Last Change:  Sep 15, 2011

if exists("b:current_syntax") && !exists ("g:syntax_debug")
  finish
endif

syn case match
syntax sync fromstart
setlocal iskeyword+=-

" special sequences, common data types, comments, includes {{{1
" hilight errors with this
syn match sdErr contained /\s*\S\+/ nextgroup=sdErr

" environment args and format strings
syn match sdEnvArg    contained /\$\i\+\|\${\i\+}/
syn match sdFormatStr contained /%[bCEfhHiIjJLmnNpPsStTgGuUvV%]/ containedin=ALLBUT,sdComment,sdErr

" common data types
syn match sdUInt     contained nextgroup=sdErr /\d\+/
syn match sdInt      contained nextgroup=sdErr /-\=\d\+/
syn match sdOctal    contained nextgroup=sdErr /0\o\{3,4}/
" sdDuration, sdCalendar: see systemd.time(7)
syn match sdDuration contained nextgroup=sdErr /\d\+/
syn match sdDuration contained nextgroup=sdErr /\%(\d\+\s*\%(usec\|msec\|seconds\=\|minutes\=\|hours\=\|days\=\|weeks\=\|months\=\|years\=\|us\|ms\|sec\|min\|hr\|[smhdwMy]\)\s*\)\+/
syn match sdDatasize contained nextgroup=sdErr /\d\+[KMGT]/
syn match sdFilename contained nextgroup=sdErr /\%(%h\)\?\/\S*/
syn match sdPercent  contained nextgroup=sdErr /\d\+%/
syn keyword sdBool   contained nextgroup=sdErr 1 yes true on 0 no false off
syn match sdUnitName contained /\S\+\.\(automount\|mount\|swap\|socket\|service\|target\|path\|timer\|device\|slice\|scope\)\_s/

" type identifiers used in `systemd --dump-config`, from most to least common:
" 189 OTHER
" 179 BOOLEAN
" 136 LIMIT
"  46 CONDITION
"  36 WEIGHT
"  30 MODE
"  27 PATH
"  25 PATH [...]
"  24 SECONDS, STRING
"  20 SIGNAL
"  15 UNIT [...]
"  12 BANDWIDTH, DEVICEWEIGHT, SHARES, UNSIGNED
"  11 PATH [ARGUMENT [...]]
"   8 BOUNDINGSET, LEVEL, OUTPUT, PATH[:PATH[:OPTIONS]] [...], SOCKET [...]
"   6 ACTION, DEVICE, DEVICELATENCY, POLICY, SLICE, TIMER
"   5 KILLMODE
"   4 ARCHS, CPUAFFINITY, CPUSCHEDPOLICY, CPUSCHEDPRIO, ENVIRON, ERRNO, FACILITY, FAMILIES, FILE, INPUT, IOCLASS, IOPRIORITY, LABEL, MOUNTFLAG [...], NAMESPACES, NANOSECONDS, NICE, NOTSUPPORTED, OOMSCOREADJUST, PERSONALITY, SECUREBITS, SYSCALLS
"   3 INTEGER, SIZE, STATUS
"   2 LONG, UNIT
"   1 ACCESS, NETWORKINTERFACE, SERVICE, SERVICERESTART, SERVICETYPE, SOCKETBIND, SOCKETS, TOS, URL


" .include
syn match sdInclude /^.include/ nextgroup=sdFilename

" comments
syn match   sdComment /^[;#].*/ contains=sdTodo containedin=ALL
syn keyword sdTodo contained TODO XXX FIXME NOTE

" [Unit] {{{1
" see systemd.unit(5)
syn region sdUnitBlock matchgroup=sdHeader start=/^\[Unit\]/ end=/^\[/me=e-2 contains=sdUnitKey
syn match sdUnitKey contained /^Description=/
syn match sdUnitKey contained /^Documentation=/ nextgroup=sdDocURI
syn match sdUnitKey contained /^SourcePath=/ nextgroup=sdFilename,sdErr
syn match sdUnitKey contained /^\%(Requires\|RequiresOverridable\|Requisite\|RequisiteOverridable\|Wants\|Binds\=To\|PartOf\|Conflicts\|Before\|After\|OnFailure\|Names\|Propagates\=ReloadTo\|ReloadPropagatedFrom\|PropagateReloadFrom\|JoinsNamespaceOf\)=/ nextgroup=sdUnitList
syn match sdUnitKey contained /^\%(OnFailureIsolate\|IgnoreOnIsolate\|IgnoreOnSnapshot\|StopWhenUnneeded\|RefuseManualStart\|RefuseManualStop\|AllowIsolate\|DefaultDependencies\)=/ nextgroup=sdBool,sdErr
syn match sdUnitKey contained /^OnFailureJobMode=/ nextgroup=sdFailJobMode,sdErr
syn match sdUnitKey contained /^\%(StartLimitInterval\|StartLimitIntervalSec\|JobTimeoutSec\)=/ nextgroup=sdDuration,sdErr
syn match sdUnitKey contained /^\%(StartLimitAction\|JobTimeoutAction\)=/ nextgroup=sdLimitAction,sdErr
syn match sdUnitKey contained /^StartLimitBurst=/ nextgroup=sdUInt,sdErr
syn match sdUnitKey contained /^\%(FailureAction\|SuccessAction\)=/ nextgroup=sdLimitAction,sdFailAction,sdErr
syn match sdUnitKey contained /^\%(FailureAction\|SuccessAction\)ExitStatus=/ nextgroup=sdExitStatus,sdErr
syn match sdUnitKey contained /^\%(RebootArgument\|JobTimeoutRebootArgument\)=/
syn match sdUnitKey contained /^RequiresMountsFor=/ nextgroup=sdFileList,sdErr
" TODO: JobRunningTimeoutSec
" ConditionXXX/AssertXXX. Note that they all have an optional '|' after the '='.
syn match sdUnitKey contained /^\%(Condition\|Assert\)\(PathExists\|PathExistsGlob\|PathIsDirectory\|PathIsMountPoint\|PathIsReadWrite\|PathIsSymbolicLink\|DirectoryNotEmpty\|FileNotEmpty\|FileIsExecutable\)=|\=!\=/ contains=sdConditionFlag nextgroup=sdFilename,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Virtualization=|\=!\=/ contains=sdConditionFlag nextgroup=sdVirtType,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Security=|\=!\=/ contains=sdConditionFlag nextgroup=sdSecurityType,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Capability=|\=!\=/ contains=sdConditionFlag nextgroup=sdAnyCapName,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)\%(KernelCommandLine\|Host\)=|\=!\=/ contains=sdConditionFlag
syn match sdUnitKey contained /^\%(Condition\|Assert\)\%(ACPower\|Null\|FirstBoot\)=|\=/ contains=sdConditionFlag nextgroup=sdBool,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)NeedsUpdate=|\=!\=/ contains=sdConditionFlag nextgroup=sdCondUpdateDir,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Architecture=|\=!\=/ contains=sdConditionFlag nextgroup=sdArch,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)User=|\=/ contains=sdConditionFlag nextgroup=sdUser,sdCondUser,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)Group=|\=/ contains=sdConditionFlag nextgroup=sdUser,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)ControlGroupController=|\=/ contains=sdConditionFlag nextgroup=sdController,sdErr
syn match sdUnitKey contained /^\%(Condition\|Assert\)KernelVersion=|\=/ contains=sdConditionFlag nextgroup=sdKernelVersion,sdErr

" extra bits
syn match sdUnitList       contained /.*/ contains=sdUnitName,sdErr
syn match sdConditionFlag  contained /[!|]/
syn match sdCondUpdateDir  contained nextgroup=sdErr /\%(\/etc\|\/var\)/
syn keyword sdVirtType     contained nextgroup=sdErr vm container qemu kvm zvm vmware microsoft oracle xen bochs uml bhyve qnx openvz openvz lxc lxc-libvirt systemd-nspawn docker podman rkt wsl acrn private-users
syn keyword sdSecurityType contained nextgroup=sdErr selinux apparmor tomoyo ima smack audit uefi-secureboot
syn keyword sdFailJobMode  contained nextgroup=sdErr fail replace replace-irreversibly
syn keyword sdLimitAction  contained nextgroup=sdErr none reboot reboot-force reboot-immediate poweroff poweroff-force poweroff-immediate
syn keyword sdFailAction   contained nextgroup=sdErr exit exit-force
syn keyword sdArch         contained nextgroup=sdErr x86 x86_64 ppc ppc-le ppc64 ppc64-le ia64 parisc parisc64 s390 s390x sparc sparc64 mips mips-le mips64 mips64-le alpha arm arm-be arm64 arm64-be sh sh64 m68k tilegx cris arc arc-be native
syn keyword sdController   contained cpu cpuacct io blkio memory devices pids nextgroup=sdController,sdErr
syn match sdCondUser       contained /@system/
syn match sdUser           contained nextgroup=sdErr /\d\+\|[A-Za-z_%][A-Za-z0-9_%-]*/
syn match sdExitStatus     contained nextgroup=sdErr /\d\|\d\d\|[01]\d\d\|2[0-4]\d\|25[0-5]/
syn match sdDocUri         contained /\%(https\=:\/\/\|file:\|info:\|man:\)\S\+\s*/ nextgroup=sdDocUri,sdErr

" [Install] {{{1
" see systemd.unit(5)
syn region sdInstallBlock matchgroup=sdHeader start=/^\[Install\]/ end=/^\[/me=e-2 contains=sdInstallKey
syn match sdInstallKey contained /^\%(WantedBy\|Alias\|Also\|RequiredBy\)=/ nextgroup=sdUnitList
syn match sdInstallKey contained /^DefaultInstance=/ nextgroup=sdInstance
" TODO: sdInstance - what's valid there? probably [^@/]\+, but that's a guess

" Execution options common to [Service|Socket|Mount|Swap] {{{1
" see systemd.exec(5)
syn match sdExecKey contained /^Exec\%(Start\%(Pre\|Post\|\)\|Reload\|Stop\|StopPost\|Condition\)=/ nextgroup=sdExecFlag,sdExecFile,sdErr
syn match sdExecKey contained /^\%(WorkingDirectory\|RootDirectory\|TTYPath\|RootImage\)=/ nextgroup=sdFilename,sdErr
syn match sdExecKey contained /^\%(Runtime\|State\|Cache\|Logs\|Configuration\)Directory=/ nextgroup=sdFilename,sdErr
syn match sdExecKey contained /^\%(Runtime\|State\|Cache\|Logs\|Configuration\)DirectoryMode=/ nextgroup=sdOctal,sdErr
syn match sdExecKey contained /^User=/ nextgroup=sdUser,sdErr
syn match sdExecKey contained /^Group=/ nextgroup=sdUser,sdErr
" TODO: NUMAPolicy, NUMAMask
" TODO: Pass/UnsetEnvironment
" TODO: StandardInput\%(Text\|Data\)
" TODO: Generally everything from 'WorkingDirectory' on down
" TODO: handle some of these better
" FIXME: some of these have moved to Resource Control
" CPUAffinity is: list of uint
" BlockIOWeight is: uint\|filename uint
" BlockIO\%(Read\|Write\)Bandwidth is: filename datasize
syn match sdExecKey contained /^\%(SupplementaryGroups\|CPUAffinity\|SyslogIdentifier\|PAMName\|TCPWrapName\|ControlGroup\|ControlGroupAttribute\|UtmpIdentifier\)=/
syn match sdExecKey contained /^Limit\%(CPU\|FSIZE\|DATA\|STACK\|CORE\|RSS\|NOFILE\|AS\|NPROC\|MEMLOCK\|LOCKS\|SIGPENDING\|MSGQUEUE\|NICE\|RTPRIO\|RTTIME\)=/ nextgroup=sdRlimit
syn match sdExecKey contained /^\%(CPUSchedulingResetOnFork\|TTYReset\|TTYVHangup\|TTYVTDisallocate\|SyslogLevelPrefix\|ControlGroupModify\|DynamicUser\|RemoveIPC\|NoNewPrivileges\|RestrictRealtime\|RestrictSUIDSGID\|LockPersonality\|MountAPIVFS\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^Private\%(Tmp\|Network\|Devices\|Users\|Mounts\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^Protect\%(KernelTunables\|KernelModules\|KernelLogs\|Clock\|ControlGroups\|Hostname\|Home\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^\%(Nice\|OOMScoreAdjust\)=/ nextgroup=sdInt,sdErr
syn match sdExecKey contained /^\%(CPUSchedulingPriority\|TimerSlackNSec\)=/ nextgroup=sdUInt,sdErr
syn match sdExecKey contained /^\%(ReadWrite\|ReadOnly\|Inaccessible\)Paths=/ nextgroup=sdFileList
syn match sdExecKey contained /^CapabilityBoundingSet=/ nextgroup=sdCapNameList
syn match sdExecKey contained /^Capabilities=/ nextgroup=sdCapability,sdErr
syn match sdExecKey contained /^UMask=/ nextgroup=sdOctal,sdErr
syn match sdExecKey contained /^StandardInput=/ nextgroup=sdStdin,sdErr
syn match sdExecKey contained /^Standard\%(Output\|Error\)=/ nextgroup=sdStdout,sdErr
syn match sdExecKey contained /^SecureBits=/ nextgroup=sdSecureBitList
syn match sdExecKey contained /^SyslogFacility=/ nextgroup=sdSyslogFacil,sdErr
syn match sdExecKey contained /^SyslogLevel=/ nextgroup=sdSyslogLevel,sdErr
syn match sdExecKey contained /^IOSchedulingClass=/ nextgroup=sdIOSchedClass,sdErr
syn match sdExecKey contained /^IOSchedulingPriority=/ nextgroup=sdIOSchedPrio,sdErr
syn match sdExecKey contained /^CPUSchedulingPolicy=/ nextgroup=sdCPUSchedPol,sdErr
syn match sdExecKey contained /^MountFlags=/ nextgroup=sdMountFlags,sdErr
syn match sdExecKey contained /^\%(IgnoreSIGPIPE\|MemoryDenyWriteExecute\)=/ nextgroup=sdBool,sdErr
syn match sdExecKey contained /^Environment=/ nextgroup=sdEnvDefs
syn match sdExecKey contained /^UnsetEnvironment=/ nextgroup=sdEnvName
syn match sdExecKey contained /^EnvironmentFile=-\=/ contains=sdEnvDashFlag nextgroup=sdFilename,sdErr

syn match   sdExecFlag      contained /-\=@\=/ nextgroup=sdExecFile,sdErr
syn match   sdExecFile      contained /\S\+/ nextgroup=sdExecArgs
syn match   sdExecArgs      contained /.*/ contains=sdEnvArg
syn match   sdEnvDefs       contained /.*/ contains=sdEnvDef,sdEnvSQuotes,sdEnvDQuotes
syn match   sdEnvDashFlag   contained /-/ nextgroup=sdFilename,sdErr
syn match   sdEnvDef        contained /\i\+=/he=e-1 nextgroup=sdEnvValue
syn match   sdEnvDefQuoted  contained /['"]\@<=\i\+=/he=e-1
hi link sdEnvDefQuoted sdEnvDef
syn match   sdEnvName       contained /\i\+/
hi link sdEnvName sdEnvDef
syn region  sdEnvSQuotes    contained start=/'/ skip=+\\'+ end=/'/ contains=sdEnvDefQuoted
syn region  sdEnvDQuotes    contained start=/"/ skip=+\\"+ end=/"/ contains=sdEnvDefQuoted
syn match   sdEnvValue      contained /\S*/
syn match   sdFileList      contained /.*/ contains=sdFilename,sdErr
" CAPABILITIES WOOO {{{
syn case ignore
syn match   sdCapNameList   contained /.*/ contains=sdAnyCapName,sdErr
syn match   sdAnyCapName    contained /CAP_[A-Z_]\+\s*/ contains=sdCapName
syn keyword sdCapName       contained CAP_AUDIT_CONTROL CAP_AUDIT_WRITE CAP_CHOWN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH
syn keyword sdCapName       contained CAP_FOWNER CAP_FSETID CAP_IPC_LOCK CAP_IPC_OWNER CAP_KILL CAP_LEASE
syn keyword sdCapName       contained CAP_LINUX_IMMUTABLE CAP_MAC_ADMIN CAP_MAC_OVERRIDE CAP_MKNOD
syn keyword sdCapName       contained CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_BROADCAST CAP_NET_RAW
syn keyword sdCapName       contained CAP_SETGID CAP_SETFCAP CAP_SETPCAP CAP_SETUID
syn keyword sdCapName       contained CAP_SYS_ADMIN CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT
syn keyword sdCapName       contained CAP_SYS_PTRACE CAP_SYS_RAWIO CAP_SYS_RESOURCE CAP_SYS_TIME CAP_SYS_TTY_CONFIG
syn case match
syn cluster sdCap           contains=sdCapName,sdCapOps,sdCapFlags
syn match   sdCapOps        contained /[=+-]/
syn match   sdCapFlags      contained /\<[eip]\+/
syn match   sdCapability    contained /\%(\%([A-Za-z_]\+,\=\)*\|all\)\%(=[eip]*\|[+-][eip]\+\)\s*/ contains=@sdCap nextgroup=sdCapability,sdErr
"}}}
syn keyword sdStdin         contained nextgroup=sdErr null tty-force tty-fail socket tty
syn match   sdStdout        contained nextgroup=sdErr /\%(syslog\|kmsg\|journal\)\%(+console\)\=/
syn keyword sdStdout        contained nextgroup=sdErr inherit null tty socket
syn match   sdStdout        contained /fd:/
syn match   sdStdout        contained nextgroup=sdFilename,sdErr /\v%(file|append):/
syn keyword sdSyslogFacil   contained nextgroup=sdErr kern user mail daemon auth syslog lpr news uucp cron authpriv ftp
syn match   sdSyslogFacil   contained nextgroup=sdErr /\<local[0-7]\>/
syn keyword sdSyslogLevel   contained nextgroup=sdErr emerg alert crit err warning notice info debug
syn keyword sdIOSchedClass  contained nextgroup=sdErr 0 1 2 3 none realtime best-effort idle
syn keyword sdIOSchedPrio   contained nextgroup=sdErr 0 1 2 3 4 5 6 7
syn keyword sdCPUSchedPol   contained nextgroup=sdErr other batch idle fifo rr
syn keyword sdMountFlags    contained nextgroup=sdErr shared slave private
syn match   sdRlimit        contained nextgroup=sdErr /\<\%(\d\+\|infinity\)\>/
syn keyword sdSecureBits    contained nextgroup=sdErr keep-caps keep-caps-locked noroot noroot-locked no-setuid-fixup no-setuid-fixup-locked

" TODO: which section does this come from?
syn match sdExecKey  contained /^TimeoutSec=/ nextgroup=sdDuration,sdErr

" Process killing options for [Service|Socket|Mount|Swap|Scope] {{{1
" see systemd.kill(5)
syn match sdKillKey  contained /^KillSignal=/ nextgroup=sdSignal,sdOtherSignal,sdErr
syn match sdKillKey  contained /^KillMode=/ nextgroup=sdKillMode,sdErr
syn match sdKillKey  contained /^\%(SendSIGKILL\|SendSIGHUP\)=/ nextgroup=sdBool,sdErr

syn keyword sdSignal      contained nextgroup=sdErr SIGHUP SIGINT SIGQUIT SIGKILL SIGTERM SIGUSR1 SIGUSR2
syn match   sdOtherSignal contained nextgroup=sdErr /\<\%(\d\+\|SIG[A-Z]\{2,6}\)\>/
syn match   sdKillMode    contained nextgroup=sdErr /\%(control-group\|mixed\|process\|none\)/

" Resource Control options for [Service|Socket|Mount|Swap|Slice|Scope] {{{1
" see systemd.resource-control(5)
syn match sdResCtlKey contained /^Slice=/ nextgroup=sdSliceName,sdErr
syn match sdResCtlKey contained /^\%(CPUAccounting\|MemoryAccounting\|IOAccounting\|BlockIOAccounting\|TasksAccounting\|IPAccounting\|Delegate\)=/ nextgroup=sdBool,sdErr
syn match sdResCtlKey contained /^\%(CPUQuota\)=/ nextgroup=sdPercent,sdErr
syn match sdResCtlKey contained /^\%(CPUShares\|StartupCPUShares\)=/ nextgroup=sdUInt,sdErr
syn match sdResCtlKey contained /^MemoryLow=/ nextgroup=sdDatasize,sdPercent,sdErr
syn match sdResCtlKey contained /^\%(MemoryLimit\|MemoryHigh\|MemoryMax\)=/ nextgroup=sdDatasize,sdPercent,sdInfinity,sdErr
syn match sdResCtlKey contained /^TasksMax=/ nextgroup=sdUInt,sdInfinity,sdErr
syn match sdResCtlKey contained /^\%(IOWeight\|StartupIOWeight\|BlockIOWeight\|StartupBlockIOWeight\)=/ nextgroup=sdUInt,sdErr
syn match sdResCtlKey contained /^DeviceAllow=/ nextgroup=sdDevAllow,sdErr
syn match sdResCtlKey contained /^DevicePolicy=/ nextgroup=sdDevPolicy,sdErr

syn match sdSliceName contained /\S\+\.slice\_s/ contains=sdUnitName
syn keyword sdInfinity contained infinity

syn match   sdDevAllow      contained /\%(\/dev\/\|char-\|block-\)\S\+\s\+/ nextgroup=sdDevAllowPerm
syn match   sdDevAllowPerm  contained /\S\+/ contains=sdDevAllowErr nextgroup=sdErr
syn match   sdDevAllowErr   contained /[^rwm]\+/
syn keyword sdDevPolicy     contained strict closed auto

" [Service] {{{1
syn region sdServiceBlock matchgroup=sdHeader start=/^\[Service\]/ end=/^\[/me=e-2 contains=sdServiceKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdServiceKey contained /^BusName=/
syn match sdServiceKey contained /^\%(RemainAfterExit\|GuessMainPID\|PermissionsStartOnly\|RootDirectoryStartOnly\|NonBlocking\|ControlGroupModify\)=/ nextgroup=sdBool,sdErr
syn match sdServiceKey contained /^\%(SysVStartPriority\|FsckPassNo\)=/ nextgroup=sdUInt,sdErr
syn match sdServiceKey contained /^\%(Restart\|Timeout\|TimeoutStart\|TimeoutStop\|TimeoutAbort\|Watchdog\|RuntimeMax\)Sec=/ nextgroup=sdDuration,sdErr
syn match sdServiceKey contained /^Sockets=/ nextgroup=sdUnitList
syn match sdServiceKey contained /^PIDFile=/ nextgroup=sdFilename,sdErr
syn match sdServiceKey contained /^Type=/ nextgroup=sdServiceType,sdErr
syn match sdServiceKey contained /^Restart=/ nextgroup=sdRestartType,sdErr
syn match sdServiceKey contained /^NotifyAccess=/ nextgroup=sdNotifyType,sdErr
syn match sdServiceKey contained /^StartLimitInterval=/ nextgroup=sdDuration,sdErr
syn match sdServiceKey contained /^StartLimitAction=/ nextgroup=sdLimitAction,sdErr
syn match sdServiceKey contained /^StartLimitBurst=/ nextgroup=sdUInt,sdErr
syn match sdServiceKey contained /^FailureAction=/ nextgroup=sdLimitAction,sdFailAction,sdErr
syn match sdServiceKey contained /^\%(RestartPrevent\|RestartForce\|Success\)ExitStatus=/ nextgroup=sdExitStatus,sdErr
syn match sdServiceKey contained /^RebootArgument=/
syn keyword sdServiceType contained nextgroup=sdErr simple exec forking dbus oneshot notify idle
syn keyword sdRestartType contained nextgroup=sdErr no on-success on-failure on-abort always
syn keyword sdNotifyType  contained nextgroup=sdErr none main all

" [Socket] {{{1
syn region sdSocketBlock matchgroup=sdHeader start=/^\[Socket\]/ end=/^\[/me=e-2 contains=sdSocketKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdSocketKey contained /^Listen\%(Stream\|Datagram\|SequentialPacket\|FIFO\|Special\|Netlink\|MessageQueue\)=/
syn match sdSocketKey contained /^Listen\%(FIFO\|Special\)=/ nextgroup=sdFilename,sdErr
syn match sdSocketKey contained /^\%(Socket\|Directory\)Mode=/ nextgroup=sdOctal,sdErr
syn match sdSocketKey contained /^\%(Backlog\|MaxConnections\|Priority\|ReceiveBuffer\|SendBuffer\|IPTTL\|Mark\|PipeSize\|MessageQueueMaxMessages\|MessageQueueMessageSize\)=/ nextgroup=sdUInt,sdErr
syn match sdSocketKey contained /^\%(Accept\|KeepAlive\|FreeBind\|Transparent\|Broadcast\|Writable\|NoDelay\|PassCredentials\|PassSecurity\|ReusePort\|RemoveOnStop\|SELinuxContextFromNet\)=/ nextgroup=sdBool,sdErr
syn match sdSocketKey contained /^BindToDevice=/
syn match sdSocketKey contained /^Service=/ nextgroup=sdUnitList
syn match sdSocketKey contained /^BindIPv6Only=/ nextgroup=sdBindIPv6,sdErr
syn match sdSocketKey contained /^IPTOS=/ nextgroup=sdIPTOS,sdUInt,sdErr
syn match sdSocketKey contained /^TCPCongestion=/ nextgroup=sdTCPCongest
syn keyword sdBindIPv6   contained nextgroup=sdErr default both ipv6-only
syn keyword sdIPTOS      contained nextgroup=sdErr low-delay throughput reliability low-cost
syn keyword sdTCPCongest contained nextgroup=sdErr westwood veno cubic lp

" [Timer|Automount|Mount|Swap|Path|Slice|Scope] {{{1
" [Timer]
syn region sdTimerBlock matchgroup=sdHeader start=/^\[Timer\]/ end=/^\[/me=e-2 contains=sdTimerKey
syn match sdTimerKey contained /^On\%(Active\|Boot\|Startup\|UnitActive\|UnitInactive\)Sec=/ nextgroup=sdDuration,sdErr
syn match sdTimerKey contained /^\%(Accuracy\|RandomizedDelay\)Sec=/ nextgroup=sdDuration,sdErr
syn match sdTimerKey contained /^\%(Persistent\|WakeSystem\|RemainAfterElapse\|OnClockChange\|OnTimezoneChange\)=/ nextgroup=sdBool,sdErr
syn match sdTimerKey contained /^OnCalendar=/ nextgroup=sdCalendar
syn match sdTimerKey contained /^Unit=/ nextgroup=sdUnitList
" TODO: sdCalendar

" [Automount]
syn region sdAutoMountBlock matchgroup=sdHeader start=/^\[Automount\]/ end=/^\[/me=e-2 contains=sdAutomountKey
syn match sdAutomountKey contained /^Where=/ nextgroup=sdFilename,sdErr
syn match sdAutomountKey contained /^DirectoryMode=/ nextgroup=sdOctal,sdErr

" [Mount]
syn region sdMountBlock matchgroup=sdHeader start=/^\[Mount\]/ end=/^\[/me=e-2 contains=sdMountKey,sdAutomountKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdMountKey contained /^\%(SloppyOptions\|LazyUnmount\|ForceUnmount\)=/ nextgroup=sdBool,sdErr
syn match sdMountKey contained /^\%(What\|Type\|Options\)=/

" [Swap]
syn region sdSwapBlock matchgroup=sdHeader start=/^\[Swap\]/ end=/^\[/me=e-2 contains=sdSwapKey,sdExecKey,sdKillKey,sdResCtlKey
syn match sdSwapKey contained /^What=/ nextgroup=sdFilename,sdErr
syn match sdSwapKey contained /^Priority=/ nextgroup=sdUInt,sdErr
syn match sdSwapKey contained /^Options=/

" [Path]
syn region sdPathBlock matchgroup=sdHeader start=/^\[Path\]/ end=/^\[/me=e-2 contains=sdPathKey
syn match sdPathKey contained /^\%(PathExists\|PathExistsGlob\|PathChanged\|PathModified\|DirectoryNotEmpty\)=/ nextgroup=sdFilename,sdErr
syn match sdPathKey contained /^MakeDirectory=/ nextgroup=sdBool,sdErr
syn match sdPathKey contained /^DirectoryMode=/ nextgroup=sdOctal,sdErr
syn match sdPathKey contained /^Unit=/ nextgroup=sdUnitList

" [Slice]
syn region sdSliceBlock matchgroup=sdHeader start=/^\[Slice\]/ end=/^\[/me=e-2 contains=sdSliceKey,sdResCtlKey,sdKillKey

" [Scope]
syn region sdScopeBlock matchgroup=sdHeader start=/^\[Scope\]/ end=/^\[/me=e-2 contains=sdScopeKey,sdResCtlKey,sdKillKey
syn match sdScopeKey contained /^TimeoutStopSec=/ nextgroup=sdDuration,sdErr


" Coloring definitions {{{1
hi def link sdComment       Comment
hi def link sdTodo          Todo
hi def link sdInclude       PreProc
hi def link sdHeader        Type
hi def link sdEnvArg        PreProc
hi def link sdFormatStr     Special
hi def link sdErr           Error
hi def link sdEnvDef        Identifier
hi def link sdUnitName      PreProc
hi def link sdKey           Statement
hi def link sdValue         Constant
hi def link sdSymbol        Special

" Coloring links: keys {{{1

" It'd be nice if this worked..
"hi def link sd.\+Key           sdKey
hi def link sdUnitKey           sdKey
hi def link sdInstallKey        sdKey
hi def link sdExecKey           sdKey
hi def link sdKillKey           sdKey
hi def link sdResCtlKey         sdKey
hi def link sdSocketKey         sdKey
hi def link sdServiceKey        sdKey
hi def link sdServiceCommonKey  sdKey
hi def link sdTimerKey          sdKey
hi def link sdMountKey          sdKey
hi def link sdAutomountKey      sdKey
hi def link sdSwapKey           sdKey
hi def link sdPathKey           sdKey
hi def link sdScopeKey          sdKey

" Coloring links: constant values {{{1
hi def link sdInt               sdValue
hi def link sdUInt              sdValue
hi def link sdBool              sdValue
hi def link sdOctal             sdValue
hi def link sdDuration          sdValue
hi def link sdPercent           sdValue
hi def link sdInfinity          sdValue
hi def link sdDatasize          sdValue
hi def link sdVirtType          sdValue
hi def link sdServiceType       sdValue
hi def link sdNotifyType        sdValue
hi def link sdSecurityType      sdValue
hi def link sdSecureBits        sdValue
hi def link sdMountFlags        sdValue
hi def link sdKillMode          sdValue
hi def link sdFailJobMode       sdValue
hi def link sdLimitAction       sdValue
hi def link sdRestartType       sdValue
hi def link sdSignal            sdValue
hi def link sdStdin             sdValue
hi def link sdStdout            sdValue
hi def link sdSyslogFacil       sdValue
hi def link sdSyslogLevel       sdValue
hi def link sdIOSched           sdValue
hi def link sdCPUSched          sdValue
hi def link sdRlimit            sdValue
hi def link sdCapName           sdValue
hi def link sdDevPolicy         sdValue
hi def link sdDevAllowPerm      sdValue
hi def link sdDevAllowErr       Error

" Coloring links: symbols/flags {{{1
hi def link sdExecFlag          sdSymbol
hi def link sdConditionFlag     sdSymbol
hi def link sdEnvDashFlag       sdSymbol
hi def link sdCapOps            sdSymbol
hi def link sdCapFlags          Identifier
"}}}

let b:current_syntax = "systemd"
" vim: fdm=marker
