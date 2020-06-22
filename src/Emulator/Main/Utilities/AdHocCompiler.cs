//
// Copyright (c) 2010-2018 Antmicro
// Copyright (c) 2011-2015 Realtime Embedded
//
// This file is licensed under the MIT License.
// Full license text is available in 'licenses/MIT.txt'.
//
using System;
using System.CodeDom.Compiler;
using System.Linq;
using Antmicro.Renode.Exceptions;

namespace Antmicro.Renode.Utilities
{
    public class AdHocCompiler
    {
        public string Compile(string sourcePath)
        {
            var names = AppDomain.CurrentDomain.GetAssemblies().Where(x => !x.IsDynamic).Select(x => x.FullName);
            using(var provider = CodeDomProvider.CreateProvider("CSharp"))
            {
                var outputFileName = TemporaryFilesManager.Instance.GetTemporaryFile();
                var parameters = new CompilerParameters { GenerateInMemory = false, GenerateExecutable = false, OutputAssembly = outputFileName };
#if PLATFORM_LINUX
                parameters.CompilerOptions = "/langversion:experimental";
#endif
                foreach(var name in names)
                {
                    parameters.ReferencedAssemblies.Add(name);
                }

                var result = provider.CompileAssemblyFromFile(parameters, new[] { sourcePath });
                if(result.Errors.HasErrors)
                {
                    var errors = result.Errors.Cast<object>().Aggregate(string.Empty,
                                                                        (current, error) => current + ("\n" + error));
                    throw new RecoverableException(string.Format("There were compilation errors:\n{0}", errors));
                }
                return outputFileName;
            }
        }
    }
}

