# GitOps
- GitOps is a way to do Kubernetes cluster management and application delivery
- Git is a part of every developer’s toolkit.
- Pull pipeline  (more secure)
![Pull pipeline](https://lh3.googleusercontent.com/Wk1JGlUSTZQi4rRj7WnXfOwMdtI7zaM-y3SdUBB-jQV1-UmmwNk5X5qvAGZKoQp_KoAGtvlM-su9llIHNiUBD8QV0z4UyBD3o0IKqjUblMGuQqiX4cUY2XG1e_0drBy_MCxC62T8)
- audit log of all cluster changes outside of Kubernetes
- a single source of truth from which to recover after a meltdown, reducing your meantime to recovery
- consistent end-to-end workflows across your entire organization
 - Approved changes can be automatically applied to the system. 


# flux
 ![](https://fluxcd.io/img/flux-cd-diagram.png)
- [simple flux tutorial](https://github.com/bricef/gitops-tutorial)
- [Automated deployment of new container images](https://docs.fluxcd.io/en/1.17.1/references/automated-image-update.html)
    - annotations
    - semver
    - regex
- fluxctl
    - set policy
    - lock
- kustomize
