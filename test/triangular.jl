@testset "Triangular-matrix multiplication" begin
    for n in (1, 2, 3, 4),
        eltyA in (Float64, ComplexF64, Int),
            (t, uplo) in ((UpperTriangular, :U), (LowerTriangular, :L)),
                eltyB in (Float64, ComplexF64)

        A = t(eltyA == Int ? rand(1:7, n, n) : rand(eltyA, n, n))
        B = rand(eltyB, n, n)
        SA = t(SMatrix{n,n}(A.data))
        SB = SMatrix{n,n}(B)

        @test (SA*SB[:,1])::SVector{n} ≈ A*B[:,1]
        @test (SA*SB)::SMatrix{n,n} ≈ A*B
        @test (SA*transpose(SB))::SMatrix{n,n} ≈ A*transpose(B)
        @test (SA*SB')::SMatrix{n,n} ≈ A*B'
        @test (SA'*SB[:,1])::SVector{n} ≈ A'*B[:,1]
        @test (SA'*SB)::SMatrix{n,n} ≈ A'*B
        @test (SA'*SB')::SMatrix{n,n} ≈ A'*B'
        @test (transpose(SA)*SB[:,1])::SVector{n} ≈ transpose(A)*B[:,1]
        @test (transpose(SA)*SB)::SMatrix{n,n} ≈ transpose(A)*B
        @test (transpose(SA)*transpose(SB))::SMatrix{n,n} ≈ transpose(A)*transpose(B)
        @test (SB*SA)::SMatrix{n,n} ≈ B*A
        if VERSION < v"0.7-"
            @test (transpose(SB[:,1])*SA)::RowVector{<:Any,<:SVector{n}} ≈ transpose(B[:,1])*A
        else
            @test (SB[:,1]'*SA)::Adjoint{<:Any,<:SVector{n}} ≈ B[:,1]'*A
            @test (transpose(SB[:,1])*SA)::Transpose{<:Any,<:SVector{n}} ≈ transpose(B[:,1])*A
        end
        @test (transpose(SB)*SA)::SMatrix{n,n} ≈ transpose(B)*A
        @test SB[:,1]'*SA ≈ B[:,1]'*A
        @test (SB'*SA)::SMatrix{n,n} ≈ B'*A
        @test (SB*SA')::SMatrix{n,n} ≈ B*A'
        @test (SB*transpose(SA))::SMatrix{n,n} ≈ B*transpose(A)
        if VERSION < v"0.7-"
            @test (transpose(SB[:,1])*transpose(SA))::RowVector{<:Any,<:SVector{n}} ≈ transpose(B[:,1])*transpose(A)
        else
            @test (SB[:,1]'*transpose(SA))::Adjoint{<:Any,<:SVector{n}} ≈ B[:,1]'*transpose(A)
            @test (transpose(SB[:,1])*transpose(SA))::Transpose{<:Any,<:SVector{n}} ≈ transpose(B[:,1])*transpose(A)
        end
        @test (transpose(SB)*transpose(SA))::SMatrix{n,n} ≈ transpose(B)*transpose(A)
        @test (SB[:,1]'*SA') ≈ SB[:,1]'*SA'
        @test (SB'*SA')::SMatrix{n,n} ≈ B'*A'

        @test_throws DimensionMismatch SA*ones(SVector{n+1,eltyB})
        @test_throws DimensionMismatch ones(SMatrix{n+1,n+1,eltyB})*SA
        @test_throws DimensionMismatch transpose(SA)*ones(SVector{n+1,eltyB})
        @test_throws DimensionMismatch SA'*ones(SVector{n+1,eltyB})
        @test_throws DimensionMismatch ones(SMatrix{n+1,n+1,eltyB})*transpose(SA)
        @test_throws DimensionMismatch ones(SMatrix{n+1,n+1,eltyB})*SA'
    end
end

@testset "Triangular-Adjoint multiplication" begin
    for n in (1,),
        eltyA in (Float64, ComplexF64, Int),
            (t, uplo) in ((UpperTriangular, :U), (LowerTriangular, :L)),
                eltyB in (Float64, ComplexF64)

        A = t(eltyA == Int ? rand(1:7, n, n) : rand(eltyA, n, n))
        B = rand(eltyB, n)
        SA = t(SMatrix{n,n}(A.data))
        SB = transpose(SVector{n}(B))

        @test (SA*SB)::SMatrix{n,n} ≈ A*transpose(B)
        @test (SA*transpose(SB))::SVector{n} ≈ A*B
        @test (SA*SB')::SVector{n} ≈ A*conj(B)
        @test (SA'*SB)::SMatrix{n,n} ≈ A'*transpose(B)
        @test (SA'*transpose(SB))::SVector{n} ≈ A'*B
        @test (SA'*SB')::SVector{n} ≈ A'*conj(B)
        @test (transpose(SA)*SB)::SMatrix{n,n} ≈ transpose(A)*transpose(B)
        @test (transpose(SA)*transpose(SB))::SVector{n} ≈ transpose(A)*B
        @test (transpose(SA)*SB')::SVector{n} ≈ transpose(A)*conj(B)
        if VERSION < v"0.7-"
            @test (SB*SA)::RowVector{<:Any,<:SVector{n}} ≈ transpose(B)*A
            @test (SB*SA')::RowVector{<:Any,<:SVector{n}} ≈ transpose(B)*A'
            @test (SB*transpose(SA))::RowVector{<:Any,<:SVector{n}} ≈ transpose(B)*transpose(A)
        else
            @test (SB*SA)::Transpose{<:Any,<:SVector{n}} ≈ transpose(B)*A
            @test (SB*SA')::Transpose{<:Any,<:SVector{n}} ≈ transpose(B)*A'
            @test (SB*transpose(SA))::Transpose{<:Any,<:SVector{n}} ≈ transpose(B)*transpose(A)
        end
        @test (transpose(SB)*SA)::SMatrix{n,n} ≈ B*A
        @test (SB'*SA)::SMatrix{n,n} ≈ conj(B)*A
        @test (transpose(SB)*transpose(SA))::SMatrix{n,n} ≈ B*transpose(A)
        @test (transpose(SB)*SA')::SMatrix{n,n} ≈ B*A'
        @test (SB'*transpose(SA))::SMatrix{n,n} ≈ conj(B)*transpose(A)
        @test (SB'*SA')::SMatrix{n,n} ≈ conj(B)*A'
    end
end

@testset "Triangular-matrix division" begin
    for n in (1, 2, 3, 4),
        eltyA in (Float64, ComplexF64, Int),
            (t, uplo) in ((UpperTriangular, :U), (LowerTriangular, :L)),
                eltyB in (Float64, ComplexF64)

        A = t(eltyA == Int ? rand(1:7, n, n) : convert(Matrix{eltyA}, (eltyA <: Complex ? complex.(randn(n, n), randn(n, n)) : randn(n, n)) |> t -> chol(t't) |> t -> uplo == :U ? t : adjoint(t)))
        B = convert(Matrix{eltyB}, eltyA <: Complex ? real(A)*ones(n, n) : A*ones(n, n))
        SA = t(SMatrix{n,n}(A.data))
        SB = SMatrix{n,n}(B)

        @test (SA\SB[:,1])::SVector{n} ≈ A\B[:,1]
        @test (SA\SB)::SMatrix{n,n} ≈ A\B
        @test (transpose(SA)\SB[:,1])::SVector{n} ≈ transpose(A)\B[:,1]
        @test (transpose(SA)\SB)::SMatrix{n,n} ≈ transpose(A)\B
        @test (SA'\SB[:,1])::SVector{n} ≈ A'\B[:,1]
        @test (SA'\SB)::SMatrix{n,n} ≈ A'\B

        @test_throws DimensionMismatch SA\ones(SVector{n+2,eltyB})
        @test_throws DimensionMismatch transpose(SA)\ones(SVector{n+2,eltyB})
        @test_throws DimensionMismatch SA'\ones(SVector{n+2,eltyB})

        @test_throws LinearAlgebra.SingularException t(zeros(SMatrix{n,n,eltyA}))\ones(SVector{n,eltyB})
        @test_throws LinearAlgebra.SingularException t(transpose(zeros(SMatrix{n,n,eltyA})))\ones(SVector{n,eltyB})
        @test_throws LinearAlgebra.SingularException t(zeros(SMatrix{n,n,eltyA}))'\ones(SVector{n,eltyB})
    end
end
