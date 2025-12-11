<div className="min-h-screen bg-gradient-to-br from-blue-600/10 via-white to-gray-200 flex items-center justify-center p-4">
  <div className="bg-white/80 backdrop-blur-sm p-8 rounded-2xl shadow-2xl w-full max-w-md border border-gray-200">
    
    <div className="text-center mb-8">
      <div className="inline-block p-3 bg-blue-600 rounded-full mb-4 shadow-lg">
        <svg 
          className="w-8 h-8 text-white" 
          fill="none" 
          stroke="currentColor" 
          viewBox="0 0 24 24"
        >
          <path 
            strokeLinecap="round" 
            strokeLinejoin="round" 
            strokeWidth={2} 
            d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" 
          />
        </svg>
      </div>

      <h1 className="text-4xl font-bold text-blue-600 mb-2">
        Iniciar Sesión
      </h1>

      <p className="text-gray-500">
        Ingresa tus credenciales para continuar
      </p>
    </div>

    <form onSubmit={handleSubmit} className="flex flex-col gap-5">
      
      {/* Email */}
      <div className="relative">
        <label htmlFor="email" className="block text-sm font-semibold text-gray-700 mb-2">
          Correo electrónico
        </label>
        <div className="relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
            </svg>
          </div>
          <input
            id="email"
            type="email"
            className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-xl shadow-sm 
            focus:ring-2 focus:ring-blue-600 focus:border-blue-600 
            transition-all duration-200 outline-none bg-white"
            placeholder="tu@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
      </div>

      {/* Contraseña */}
      <div className="relative">
        <label htmlFor="password" className="block text-sm font-semibold text-gray-700 mb-2">
          Contraseña
        </label>
        <div className="relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
          </div>
          <input
            id="password"
            type="password"
            className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-xl shadow-sm 
            focus:ring-2 focus:ring-blue-600 focus:border-blue-600 
            transition-all duration-200 outline-none bg-white"
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
      </div>

      {/* Botón */}
      <button
        className="w-full mt-2 bg-blue-600 hover:bg-blue-700 
        text-white font-bold py-3.5 px-4 rounded-xl transition-all duration-300 
        disabled:bg-gray-300 disabled:cursor-not-allowed 
        shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 disabled:transform-none"
        type="submit"
        disabled={!email.trim() || !password.trim()}
      >
        Iniciar Sesión
      </button>
    </form>

    <div className="mt-6 text-center">
      <p className="text-sm text-gray-600">
        ¿No tienes una cuenta?{" "}
        <Link to="/register" className="text-blue-600 hover:text-blue-700 font-semibold transition-colors">
          Regístrate aquí
        </Link>
      </p>
    </div>

  </div>
</div>
